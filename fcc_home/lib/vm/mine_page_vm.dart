import 'dart:convert';
import 'dart:isolate';

import 'package:fcc_home/entity/file_info.dart';
import 'package:fcc_home/home_global.dart';
import 'package:fcc_home/net_client.dart';
import 'package:fcc_home/repo/file_info_repo.dart';
import 'package:fcc_home/repo/local_db_helper.dart';
import 'package:fcc_home/vm/detail_virtual_vm.dart';
import 'package:flutter/material.dart';

import '../util/fileCrypto.dart';

//test
void wtd(SendPort port) {
  Isolate.exit(port, "welldone");
}

//generate md5
Future<void> genMd5s(List<dynamic> args) async {
  List<String> md5s = [];
  List<SyncInfo> entries = args[1];
  print("file numbers ${entries.length}");
  var map = {};
  for (var entity in entries) {
    var md5 = await getFileHash(entity.uri);
    entity.md5 = md5;
    md5s.add(md5);
    map[entity.uri] = md5;
  }
  Isolate.exit(args[0], map);
}


class MinePageVM {
  MineFiles mineEntries = MineFiles();

  //全图片路径数据
  List<String> entries = [];

  // List<SyncInfo> syncEntries = [];

  MineVirualVM? detailVm;

  var client = NetClient();

  Future<void> initData() async {
    await initDatas();

    checkFilesSyncState();
  }

  //获取并刷新数据(默认已同步)
  Future<void> initDatas() async {
    List<SyncInfo> syncFiles = [];

    List<Map<String, dynamic>> datas = [];

    dynamic result =
        await HomeGlobal.platform.invokeMethod("requestPermission");
    print(result);
    if (result == true) {
      print("next step");
      dynamic pics = await HomeGlobal.platform.invokeListMethod("getAllPics");
      // print(pics);
      List<String> picsPath = [];
      for (String pic in pics) {
        Map<String, dynamic> picsMap = json.decode(pic);
        // print(picsMap['data']);
        picsPath.add(picsMap['data']);
        datas.add(picsMap);

        SyncInfo info;

        if (picsMap['thumb'] != null &&
            picsMap['thumb'].toString().isNotEmpty) {
          info = SyncInfo(
              name: picsMap['name'],
              uri: picsMap['data'],
              thumb: picsMap['thumb']);
        } else {
          info = SyncInfo(
              name: picsMap['name'],
              uri: picsMap['data'],
              thumb: picsMap['data']);
        }
        syncFiles.add(info);
      }
      entries = picsPath;
      mineEntries.refreshFiles(syncFiles);
      // (_pageWidget[0] as MinePageWidget).setList(picsPath);
      detailVm = MineVirualVM(datas);
    }
    // _initApp();
    // _listenToEvent();
  }

  void checkFilesSyncState() async {
    var dbHelper = LocalDBHelper();
    await dbHelper.initDB();
    await refreshMd5ByIsolate(dbHelper);

    //todo test
    var uris = mineEntries.localEntries.map((e) => e.uri).toList();
    var existFiles = await dbHelper.retrieveFilesByPath(uris);
    var waitToChecks = existFiles.map((e) => e.md5).toList();

    var start = 0;
    while (start < waitToChecks.length) {
      var end = start + 100;
      if (end > waitToChecks.length) {
        end = waitToChecks.length;
      }
      print("check list from $start to $end");
      var checkList = waitToChecks.sublist(start, end);
      await checkAndRefreshData(checkList, existFiles);
      // todo update files sync status in local
      // dbHelper.updateFileInfos(files);
      start = end;
    }
  }

  //check and init file md5s in local db
  Future<void> refreshMd5ByIsolate(dbHelper) async {
    var uris = mineEntries.localEntries.map((e) => e.uri).toList();

    var existFiles = await dbHelper.retrieveFilesByPath(uris);
    var existPath = existFiles.map((e) => e.path).toList();

    // print("exist db files: $existPath");

    List<SyncInfo>? notExistFiles;
    if (existPath.isNotEmpty) {
      notExistFiles = mineEntries.localEntries
          .where((element) => !existPath.contains(element.uri))
          .toList();
    } else {
      notExistFiles = mineEntries.localEntries;
    }

    //get md5s
    final resultPort = ReceivePort();
    // 2
    SendPort port = resultPort.sendPort;
    // 3
    var isolate =
        // await Isolate.spawn(checkFileSyncTop, [port, mineEntries.syncEntries]);
        await Isolate.spawn(genMd5s, [port, notExistFiles]);
    // 4
    Map result = await resultPort.first;
    print("check files result: $result");

    if (result.isNotEmpty) {
      for (var element in mineEntries.localEntries) {
        if (result[element.uri] != null) {
          element.md5 = result[element.uri];
          print("insert new  ${element.md5}");
          dbHelper.insertFileInfo(FileInfoRepo.fromMap({
            'name': element.name,
            'path': element.uri,
            'type': element.uri.substring(element.uri.lastIndexOf('.') + 1),
            'md5': element.md5,
            'length': 0,
            'sync': false
          }));
        }
      }
    }
  }


  Future<void> checkAndRefreshData(
      waitToChecks, List<FileInfoRepo> existFiles) async {
    String? result =
        await client.checkFilesExist(waitToChecks, HomeGlobal.token);
    if (result != null) {
      print("checkFileResult");
      List<dynamic> unSyncMd5s = json.decode(result);

      for (var unSyncMd5 in unSyncMd5s) {
        var file = existFiles.firstWhere((element) => element.md5 == unSyncMd5);
        var entity = mineEntries.localEntries
            .firstWhere((element) => element.uri == file.path);
        entity.syncState = false;
      }

      mineEntries.justRefreshTheState();
    }
  }

  Future<bool> truelyUpaloadAnFile(FileInfoRepo unit) async {
    print("uploadfile ${unit.md5}");
    var uploadResult = await client.uploadLocalFile(
        unit.name, unit.path, HomeGlobal.token, unit.md5);
    print("uploadresult: $uploadResult");
    //判断是否上传成功
    if (true) {
      mineEntries.localEntries
          .firstWhere((element) => element.uri == unit.path)
          .syncState = true;
      // entity.syncState = true;
      // updateFiles.add(entity.toFileInfos());
      mineEntries.justRefreshTheState();
      return true;
    }
  }

  //upload files
  Future<void> uploadFilesByIsolate(List<SyncInfo> uploadList) async {
    var dbHelper = LocalDBHelper();
    await dbHelper.initDB();

    var uris = uploadList.map((e) => e.uri).toList();

    var localUploadInfos = await dbHelper.retrieveFilesByPath(uris);
    print("get exist db files ${localUploadInfos.length}");

    String? result = await client.checkFilesExist(
        localUploadInfos.map((e) => e.md5).toList(), HomeGlobal.token);
    if (result != null) {
      List<dynamic> unSyncMd5s = json.decode(result);
      print("check files result: $result");
      //todo bug here md5 == null
      // List<FileInfoRepo> updateFiles = [];
      //这种做法并没有办法真正await整个函数
      // localUploadInfos
      //     .where((element) => unSyncMd5s.contains(element.md5))
      //     .forEach((unit) async => await
      //       truelyUpaloadAnFile(unit)
      // );
      //需要使用future.foreach或future.await
      Iterable<FileInfoRepo> list =
          localUploadInfos.where((element) => unSyncMd5s.contains(element.md5));
      await Future.forEach(list, (element) async {
        await truelyUpaloadAnFile(element as FileInfoRepo);
      });
      print("wait upload into the end");
      //todo wait to fix
      // dbHelper.updateFileInfos(updateFiles);
    }
  }

  /// 检查文件同步状态
  Future<void> checkFileSync(List<dynamic> args) async {
    List<String> md5s = [];
    // print("file numbers ${mineEntries.syncEntries.length}");
    for (var entity in mineEntries.localEntries) {
      var md5 = await getFileHash(entity.uri);
      entity.md5 = md5;
      md5s.add(md5);
    }
    // String? result = await client.checkFilesExist(md5s, HomeGlobal.token);
    // if (result != null) {
    //   print(result);
    //   List<String> unSyncMd5s = json.decode(result);
    //   mineEntries.refreshSyncState(unSyncMd5s);
    // }
    Isolate.exit(args[0], "welldone");
  }

  //同步文件
  Future<void> syncFiles() async {
    List<SyncInfo> upload = [];
    for (var index = 0; index < mineEntries.syncMarks.length; index++) {
      if (mineEntries.syncMarks[index]) {
        upload.add(mineEntries.localEntries[index]);
      }
    }
    await uploadFilesByIsolate(upload);
  }
}

class MineFiles with ChangeNotifier {
  //all files
  List<SyncInfo> localEntries = [];

  //marks waiting for upload
  List<bool> syncMarks = [];

  void refreshFiles(List<SyncInfo> newFiles) {
    localEntries.clear();
    localEntries.addAll(newFiles);
    syncMarks = List.filled(localEntries.length, false);
    notifyListeners();
  }

  void refreshSyncState(List<String> unSyncMd5s) {
    for (var info in localEntries) {
      if (unSyncMd5s.contains(info.md5)) {
        info.syncState = false;
      }
    }
    notifyListeners();
  }

  void justRefreshTheState() {
    notifyListeners();
  }
}

class MineVirualVM extends DetailVirtualVM {
  List<Map<String, dynamic>> datas = [];

  MineVirualVM(this.datas);

  @override
  void goBack() {}

  @override
  void goToNext() {}

  @override
  Future<void> removeAt(int index) async {
    dynamic result =
        await HomeGlobal.platform.invokeMethod("delete", datas[index]['id']);
    datas.removeAt(index);
  }

  @override
  Map<String, dynamic> getInfo(int index) {
    return datas[index];
  }

  @override
  String getUrl(int index) {
    var url = datas[index]['data'];
    return url;
  }
}

class SyncInfo {
  String name;
  String uri;
  String thumb;
  String? md5;
  FileInfo? info;
  bool syncState = true;

  FileInfoRepo toFileInfos() {
    return FileInfoRepo.fromMap({
      'name': name,
      'path': uri,
      'type': uri.substring(uri.lastIndexOf('.') + 1),
      'md5': md5,
      'length': 0,
      'sync': syncState
    });
  }

  SyncInfo({required this.name, required this.uri, required this.thumb});
}