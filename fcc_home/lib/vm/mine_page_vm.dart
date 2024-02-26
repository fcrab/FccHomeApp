import 'dart:convert';
import 'dart:isolate';

import 'package:fcc_home/entity/file_info.dart';
import 'package:fcc_home/home_global.dart';
import 'package:fcc_home/net_client.dart';
import 'package:fcc_home/vm/detail_virtual_vm.dart';
import 'package:flutter/material.dart';

import '../util/fileCrypto.dart';

class MinePageVM {
  MineFiles mineEntries = MineFiles();

  List<String> entries = [];

  // List<SyncInfo> syncEntries = [];

  MineVirualVM? detailVm;

  var client = NetClient();

  Future<void> refreshDatas() async {
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

        var info = SyncInfo(uri: picsMap['data']);
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

  Future<void> checkFilesByIsolate() async {
    final resultPort = ReceivePort();
    await Isolate.spawn(checkFileSync, [resultPort.sendPort]);
    // String result =
  }

  /// 检查文件同步状态
  Future<void> checkFileSync(List<dynamic> args) async {
    List<String> md5s = [];
    print("file numbers ${mineEntries.syncEntries.length}");
    for (var entity in mineEntries.syncEntries) {
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
  Future<void> syncFiles() async {}
}

class MineFiles with ChangeNotifier {
  List<SyncInfo> syncEntries = [];

  List<bool> syncList = [];

  void refreshFiles(List<SyncInfo> newFiles) {
    syncEntries.clear();
    syncEntries.addAll(newFiles);
    syncList = List.filled(syncEntries.length, false);
    notifyListeners();
  }

  void refreshSyncState(List<String> unSyncMd5s) {
    for (var info in syncEntries) {
      if (unSyncMd5s.contains(info.md5)) {
        info.syncState = false;
      }
    }
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
  String uri;
  String? md5;
  FileInfo? info;
  bool syncState = false;

  SyncInfo({required this.uri});
}