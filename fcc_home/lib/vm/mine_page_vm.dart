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

//check file exist in server before upload
Future<void> checkFileSyncTop(List<dynamic> args) async {
  var client = NetClient();
  List<String> md5s = [];
  List<FileInfoRepo> entries = args[1];
  print("file numbers ${entries.length}");
  var map = {};
  for (var entity in entries) {
    //todo select from db
    if (entity.md5 != "") {
      md5s.add(entity.md5);
      map[entity.md5] = entity.name;
    }
  }

  String? result = await client.checkFilesExist(md5s, HomeGlobal.token);
  if (result != null) {
    print("checkFileResult: $result");
    List<dynamic> unSyncMd5s = json.decode(result);
    var resultMap = {};
    for (var md5 in unSyncMd5s) {
      resultMap[map[md5]] = md5;
    }
    // mineEntries.refreshSyncState(unSyncMd5s);
    Isolate.exit(args[0], resultMap);
  } else {
    Isolate.exit(args[0], []);
  }
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

  //upload files
  Future<void> uploadFilesByIsolate(List<SyncInfo> uploadList) async {
    var dbHelper = LocalDBHelper();
    await dbHelper.initDB();

    var uris = uploadList.map((e) => e.uri).toList();

    var existFiles = await dbHelper.retrieveFilesByPath(uris);
    // dbHelper.retrieveFileByPath(uri)
    print("get exist db files ${existFiles.length}");
    // for(var file in existFiles){
    //   print(file.path);
    // }

    // 1
    final resultPort = ReceivePort();
    // 2
    SendPort port = resultPort.sendPort;
    // 3
    var isolate =
        // await Isolate.spawn(checkFileSyncTop, [port, mineEntries.syncEntries]);
        await Isolate.spawn(checkFileSyncTop, [port, existFiles]);
    // 4
    Map result = await resultPort.first;
    print("check files result: $result");
    if (result.isNotEmpty) {
      List<FileInfoRepo> updateFiles = [];

      for (var element in mineEntries.localEntries) {
        if (result[element.name] != null) {
          element.md5 = result[element.name];
          print("uploadfile ${element.md5}");
          var uploadResult = await client.uploadLocalFile(
              element.name, element.uri, HomeGlobal.token, element.md5!);
          print("uploadresult: $uploadResult");
          //判断是否上传成功
          if (true) {
            element.syncState = true;
            updateFiles.add(FileInfoRepo.fromMap({
              'name': element.name,
              'path': element.uri,
              'type': element.uri.substring(element.uri.lastIndexOf('.') + 1),
              'md5': element.md5,
              'length': 0,
              'sync': false
            }));
          }
        } else {
          //mark local file sync
          element.syncState = true;
          updateFiles.add(FileInfoRepo.fromMap({
            'name': element.name,
            'path': element.uri,
            'type': element.uri.substring(element.uri.lastIndexOf('.') + 1),
            'md5': element.md5,
            'length': 0,
            'sync': false
          }));
        }
      }

      dbHelper.updateFileInfos(updateFiles);
      mineEntries.justRefreshTheState();
      //todo update upload result

      //todo update local db sync status

      //todo update list

      // mineEntries.refreshSyncState(result);
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

  SyncInfo({required this.name, required this.uri, required this.thumb});
}