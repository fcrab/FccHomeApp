class FileInfo {
  int id;
  String name;
  String url;
  String md5;
  DateTime createTime;
  DateTime lastModify;

  FileInfo(
      this.id, this.name, this.url, this.md5, this.createTime, this.lastModify);

  FileInfo.name(
      this.id, this.name, this.url, this.md5, this.createTime, this.lastModify);
}
