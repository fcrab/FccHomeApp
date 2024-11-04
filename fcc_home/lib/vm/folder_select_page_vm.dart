import 'package:flutter/material.dart';

import '../home_global.dart';

class FolderSelectPageVM {
  // late List<Map<String,int>> entries;
  OneFolders entries = OneFolders();

  Future<void> initData() async {
    List<Map<Object?, Object?>>? folders =
        await HomeGlobal.platform.invokeListMethod("getFolder");

    List<SyncFolder> syncFolders = [];

    folders?.forEach((element) {
      if (element["name"] != null && element["id"] != null) {
        syncFolders.add(SyncFolder(element["name"].toString(),
            element["id"].toString(), int.parse(element["count"].toString())));
      }
    });

    entries.refreshList(syncFolders);
  }
}

class OneFolders with ChangeNotifier {
  List<SyncFolder> localList = [];

  void refreshList(List<SyncFolder> newFolders) {
    localList.clear();
    localList.addAll(newFolders);

    notifyListeners();
  }
}

class SyncFolder {
  SyncFolder(this.name, this.id, this.count);

  String name;
  String id;
  int count;
}
