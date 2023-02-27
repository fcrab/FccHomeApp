import 'dart:convert';

import 'package:fcc_home/home_global.dart';
import 'package:flutter/material.dart';

import '../entity/file_info.dart';
import '../entity/folder_info.dart';
import '../net_client.dart';

class MediaServerVM {
  FileInfos listInfo = FileInfos.empty();

  DirInfos dirs = DirInfos();

  var client = NetClient();

  Future<void> fetchUserDirs() async {
    var dirList = await client.getServerDirList(HomeGlobal.token);
    if (dirList != null) {
      List listObj = json.decode(dirList);
      var list = listObj.map((e) => FolderInfo.fromJson(e)).toList();
      dirs.refresh(list);
    }
  }

  Future<void> fetchPicsData(int dir) async {
    if (listInfo.page == 0) {
      var pager = await client.getServerPicsList(HomeGlobal.token, dir, 1);
      var data = FileInfos.fromJson(json.decode(pager!));
      listInfo.refresh(data);
    } else {
      var fileInfoByPage =
          await client.getServerPicsList(HomeGlobal.token, dir, listInfo.page);
      var pager = FileInfos.fromJson(json.decode(fileInfoByPage!));
      listInfo.addNewPage(pager.dataList);
    }
  }
}

// binding data

class DirInfos with ChangeNotifier {
  List<FolderInfo> dirs = [];

  void refresh(List<FolderInfo> newData) {
    dirs = newData;
    notifyListeners();
  }
}

class FileInfos with ChangeNotifier {
  int page = 0;

  int size = 0;

  int total = 0;

  List<FileInfo> dataList = [];

  FileInfos.empty();

  FileInfos(
      {required this.page,
      required this.size,
      required this.total,
      required this.dataList});

  void refresh(FileInfos newData) {
    dataList = newData.dataList;
    total = newData.total;
    page = newData.page;
    size = newData.size;
    notifyListeners();
  }

  void addNewPage(List<FileInfo> moreData) {
    page += 1;
    dataList.addAll(moreData);
    notifyListeners();
  }

  factory FileInfos.fromJson(Map<String, dynamic> newData) {
    return FileInfos(
        page: newData['page'] as int,
        size: newData['size'] as int,
        total: newData['total'] as int,
        dataList: (newData['total'] as List)
            .map((e) => FileInfo.fromJson(e))
            .toList());
  }
}
