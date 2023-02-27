class FolderInfo {
  int id;
  String name;
  String parent;
  bool isUserBase;

  FolderInfo(
      {required this.id,
      required this.name,
      required this.parent,
      required this.isUserBase});

  factory FolderInfo.fromJson(Map<String, dynamic> obj) {
    return FolderInfo(
        id: obj['id'] as int,
        name: obj['name'] as String,
        parent: obj['parent'] as String,
        isUserBase: obj['isUserBase'] as bool);
  }
}
