class FileInfo {
  int id;
  String name;
  String url;
  String thumb;
  String md5;
  DateTime createTime;
  DateTime lastModify;

  FileInfo(
      {required this.id,
      required this.name,
      required this.url,
      required this.thumb,
      required this.md5,
      required this.createTime,
      required this.lastModify});

  factory FileInfo.fromJson(Map<String, dynamic> dataMap) {
    return FileInfo(
        id: dataMap['id'] as int,
        name: dataMap['name'],
        url: dataMap['url'],
        thumb: dataMap['thumbUrl'],
        md5: (dataMap['md5'] != null) ? dataMap['md5'] : "",
        createTime: DateTime.now(),
        lastModify: DateTime.now());

    // createTime: DateTime.parse(dataMap['createTime']),
    // lastModify: DateTime.parse(dataMap['lastModify']));
  }

  FileInfo.name(this.id, this.name, this.url, this.thumb, this.md5,
      this.createTime, this.lastModify);

  Map<String, dynamic> toInfo() {
    return {
      'name': name,
      'url': url,
      'thumb': thumb,
      "date": (createTime.millisecondsSinceEpoch ~/ 1000).toString()
    };
  }
}
