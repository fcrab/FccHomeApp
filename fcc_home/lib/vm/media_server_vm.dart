import 'dart:convert';

import 'package:fcc_home/vm/detail_virtual_vm.dart';
import 'package:flutter/material.dart';

import '../entity/file_info.dart';
import '../entity/folder_info.dart';
import '../home_global.dart';
import '../net_client.dart';

class MediaServerVM {
  // FileInfos listInfo = FileInfos.empty();

  // DirInfos dirs = DirInfos();

  MediaInfos infos = MediaInfos();

  var client = NetClient();

  Future<bool> fetchUserDataInDir(dir) async {
    try {
      var dirList = await client.getServerDirList(HomeGlobal.token, dir);

      List<FolderInfo> list = [];
      if (dirList != null) {
        List listObj = json.decode(dirList);
        list = listObj.map((e) => FolderInfo.fromJson(e)).toList();
      }
      if (dir != -1) {
        var pager = await client.getServerPicsList(HomeGlobal.token, dir, 1);
        var data = FileInfos.fromJson(json.decode(pager!));
        infos.refreshNewDirs(list, data);
      } else {
        infos.refreshNewDirs(list, FileInfos.empty());
      }
    } catch (exp) {
      print(exp.toString());
      return false;
    }

    // print("fetchUserDirs gets result");
    // if (dirList != null) {
    //   try {
    //     List listObj = json.decode(dirList);
    //     var list = listObj.map((e) => FolderInfo.fromJson(e)).toList();
    //     // dirs.refresh(list);
    //   } catch (exp) {
    //     print(exp.toString());
    //     return false;
    //   }
    // } else {
    //   return false;
    // }
    return true;
  }

  Future<bool> fetchUserDirs() async {
    // var dirList = await client.getServerDirList(HomeGlobal.token);
    //
    // print("fetchUserDirs gets result");
    // if (dirList != null) {
    //   try {
    //     List listObj = json.decode(dirList);
    //     var list = listObj.map((e) => FolderInfo.fromJson(e)).toList();
    //     dirs.refresh(list);
    //   } catch (exp) {
    //     print(exp.toString());
    //     return false;
    //   }
    // } else {
    //   return false;
    // }
    // return true;
    //test
    // dirs.refresh([
    //   FolderInfo(id: 1, name: "name1", parent: "", isUserBase: true),
    //   FolderInfo(id: 2, name: "test2", parent: "", isUserBase: false),
    //   FolderInfo(id: 3, name: "test3", parent: "", isUserBase: false),
    //   FolderInfo(id: 4, name: "test5", parent: "", isUserBase: false)
    // ]);
    var testDirs = [
      FolderInfo(id: 1, name: "name1", parent: "", isUserBase: true),
      FolderInfo(id: 2, name: "test2", parent: "", isUserBase: false),
      FolderInfo(id: 3, name: "test3", parent: "", isUserBase: false),
      FolderInfo(id: 4, name: "test5", parent: "", isUserBase: false)
    ];

    infos.refreshDir(testDirs);
    return true;
  }

  Future<bool> fetchPicsData(int dir) async {
    if (infos.fileInfos.page == 0) {
      var pager = await client.getServerPicsList(HomeGlobal.token, dir, 1);
      var data = FileInfos.fromJson(json.decode(pager!));
      infos.refreshFiles(data);
    } else {
      var fileInfoByPage = await client.getServerPicsList(
          HomeGlobal.token, dir, infos.fileInfos.page);
      var pager = FileInfos.fromJson(json.decode(fileInfoByPage!));
      infos.addNewFiles(pager.dataList);
    }
    return true;
    //test

    // if (infos.fileInfos.page == 0) {
    //   infos.refreshFiles(FileInfos(page: 1, size: 3, total: 10, dataList: [
    //     FileInfo(
    //         id: 1,
    //         name: 'test1',
    //         url:
    //             'https://img1.mydrivers.com/img/20210329/209025c28e7c443bb6e070c39b6574b9.png',
    //         md5: "",
    //         createTime: DateTime.now(),
    //         lastModify: DateTime.now()),
    //     FileInfo(
    //         id: 2,
    //         name: 'test2',
    //         url: 'https://www.zhifure.com/upload/images/2018/9/15212126838.jpg',
    //         md5: "",
    //         createTime: DateTime.now(),
    //         lastModify: DateTime.now()),
    //     FileInfo(
    //         id: 3,
    //         name: 'test3',
    //         url: 'https://www.inbar.int/wp-content/uploads/2020/12/3.jpg',
    //         md5: "",
    //         createTime: DateTime.now(),
    //         lastModify: DateTime.now()),
    //   ]));
    // } else {
    //   infos.addNewFiles([
    //     FileInfo(
    //         id: 4,
    //         name: 'test1',
    //         url:
    //             'https://tse1-mm.cn.bing.net/th/id/OIP-C.1CSkXOfFPeN3_dkp7Se4ngHaEK?pid=ImgDet&rs=1',
    //         md5: "",
    //         createTime: DateTime.now(),
    //         lastModify: DateTime.now()),
    //     FileInfo(
    //         id: 5,
    //         name: 'test2',
    //         url:
    //             'https://cdn.motor1.com/images/mgl/9LxYy/s1/2021-volkswagen-arteon.jpg',
    //         md5: "",
    //         createTime: DateTime.now(),
    //         lastModify: DateTime.now()),
    //     FileInfo(
    //         id: 6,
    //         name: 'test3',
    //         url:
    //             'https://st.automobilemag.com/uploads/sites/5/2019/05/2019-Volkswagen-Arteon.jpg',
    //         md5: "",
    //         createTime: DateTime.now(),
    //         lastModify: DateTime.now()),
    //   ]);
    // }
    // return true;
  }

  DetailVirtualVM getDisplayVm(List<FileInfo> datas) {
    return ServerVirualVM(datas);
  }
}

// binding data

// class DirInfos with ChangeNotifier {
class DirInfos {
  List<FolderInfo> dirs = [];

  void refresh(List<FolderInfo> newData) {
    dirs = newData;
    // notifyListeners();
  }
}

// class FileInfos with ChangeNotifier {
class FileInfos {
  int page = 0;

  int size = 0;

  int total = 0;

  List<FileInfo> dataList = [];

  FileInfos.empty();

  FileInfos({required this.page,
    required this.size,
    required this.total,
    required this.dataList});

  void refresh(FileInfos newData) {
    dataList = newData.dataList;
    total = newData.total;
    page = newData.page + 1;
    size = newData.size;
    // notifyListeners();
  }

  void addNewPage(List<FileInfo> moreData) {
    page += 1;
    dataList.addAll(moreData);
    // notifyListeners();
  }

  factory FileInfos.fromJson(Map<String, dynamic> newData) {
    return FileInfos(
        page: newData['page'] as int,
        size: newData['size'] as int,
        total: newData['total'] as int,
        dataList: (newData['data'] as List)
            .map((e) => FileInfo.fromJson(e))
            .toList());
  }
}

class MediaInfo {
  bool isDir = false;
  FolderInfo? folder;
  FileInfo? file;

  MediaInfo({required this.isDir, required this.folder, required this.file});
}

class MediaInfos with ChangeNotifier {
  List<MediaInfo> list = [];
  DirInfos dirInfos = DirInfos();
  FileInfos fileInfos = FileInfos.empty();

  void refreshNewDirs(List<FolderInfo> newDirs, FileInfos newFiles) {
    dirInfos.refresh(newDirs);
    fileInfos.refresh(newFiles);
    mergeData();
    notifyListeners();
  }

  void refreshDir(List<FolderInfo> newData) {
    dirInfos.refresh(newData);
    mergeData();
    notifyListeners();
  }

  void refreshFiles(FileInfos newData) {
    fileInfos.refresh(newData);
    mergeData();
    notifyListeners();
  }

  void addNewFiles(List<FileInfo> moreData) {
    fileInfos.addNewPage(moreData);
    mergeData();
    notifyListeners();
  }

  void mergeData() {
    list = [
      ...dirInfos.dirs
          .map((e) => MediaInfo(isDir: true, folder: e, file: null)),
      ...fileInfos.dataList
          .map((e) => MediaInfo(isDir: false, folder: null, file: e))
    ];
  }

  int getTotal() {
    return dirInfos.dirs.length + fileInfos.total;
  }
}

class ServerVirualVM extends DetailVirtualVM {
  List<FileInfo> datas = [];

  ServerVirualVM(this.datas);

  @override
  void goBack() {}

  @override
  void goToNext() {}

  @override
  Future<void> removeAt(int index) async {
    // dynamic result =
    // await HomeGlobal.platform.invokeMethod("delete", datas[index]['id']);
    // datas.removeAt(index);
    //todo del file from server
  }

  @override
  Map<String, dynamic> getInfo(int index) {
    return datas[index].toInfo();
  }

  @override
  String getUrl(int index) {
    // var url = datas[index].url;
    return datas[index].url;
  }
}