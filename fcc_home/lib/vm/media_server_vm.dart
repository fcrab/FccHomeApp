import 'package:flutter/material.dart';

import '../entity/file_info.dart';
import '../entity/folder_info.dart';
import '../net_client.dart';

class MediaServerVM {
  FileInfos listInfo = FileInfos.empty();

  DirInfos dirs = DirInfos();

  var client = NetClient();

  Future<bool> fetchUserDirs() async {
    // var dirList = await client.getServerDirList(HomeGlobal.token);
    //
    // print("fetchUserDirs gets result");
    // if (dirList != null) {
    //   try{
    //     List listObj = json.decode(dirList);
    //     var list = listObj.map((e) => FolderInfo.fromJson(e)).toList();
    //     dirs.refresh(list);
    //   }catch(exp){
    //     print(exp.toString());
    //     return false;
    //   }
    // }else{
    //   return false;
    // }
    // return true;
    //test
    dirs.refresh([
      FolderInfo(id: 1, name: "name1", parent: "", isUserBase: true),
      FolderInfo(id: 2, name: "test2", parent: "", isUserBase: false),
      FolderInfo(id: 3, name: "test3", parent: "", isUserBase: false),
      FolderInfo(id: 4, name: "test5", parent: "", isUserBase: false)
    ]);
    return true;
  }

  Future<bool> fetchPicsData(int dir) async {
    // if (listInfo.page == 0) {
    //   var pager = await client.getServerPicsList(HomeGlobal.token, dir, 1);
    //   var data = FileInfos.fromJson(json.decode(pager!));
    //   listInfo.refresh(data);
    // } else {
    //   var fileInfoByPage =
    //       await client.getServerPicsList(HomeGlobal.token, dir, listInfo.page);
    //   var pager = FileInfos.fromJson(json.decode(fileInfoByPage!));
    //   listInfo.addNewPage(pager.dataList);
    // }

    //test

    if (listInfo.page == 0) {
      listInfo.refresh(FileInfos(page: 1, size: 3, total: 10, dataList: [
        FileInfo(
            id: 1,
            name: 'test1',
            url:
                'https://img1.mydrivers.com/img/20210329/209025c28e7c443bb6e070c39b6574b9.png',
            md5: "",
            createTime: DateTime.now(),
            lastModify: DateTime.now()),
        FileInfo(
            id: 2,
            name: 'test2',
            url: 'https://www.zhifure.com/upload/images/2018/9/15212126838.jpg',
            md5: "",
            createTime: DateTime.now(),
            lastModify: DateTime.now()),
        FileInfo(
            id: 3,
            name: 'test3',
            url: 'https://www.inbar.int/wp-content/uploads/2020/12/3.jpg',
            md5: "",
            createTime: DateTime.now(),
            lastModify: DateTime.now()),
      ]));
    } else {
      listInfo.addNewPage([
        FileInfo(
            id: 4,
            name: 'test1',
            url:
                'https://tse1-mm.cn.bing.net/th/id/OIP-C.1CSkXOfFPeN3_dkp7Se4ngHaEK?pid=ImgDet&rs=1',
            md5: "",
            createTime: DateTime.now(),
            lastModify: DateTime.now()),
        FileInfo(
            id: 5,
            name: 'test2',
            url:
                'https://cdn.motor1.com/images/mgl/9LxYy/s1/2021-volkswagen-arteon.jpg',
            md5: "",
            createTime: DateTime.now(),
            lastModify: DateTime.now()),
        FileInfo(
            id: 6,
            name: 'test3',
            url:
                'https://st.automobilemag.com/uploads/sites/5/2019/05/2019-Volkswagen-Arteon.jpg',
            md5: "",
            createTime: DateTime.now(),
            lastModify: DateTime.now()),
      ]);
    }
    return true;
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
