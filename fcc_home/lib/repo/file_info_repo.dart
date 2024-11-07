// docs https://docs.flutter.dev/cookbook/persistence/sqlite
class FileInfoRepo {
  // final int id;
  final String name;
  final String path;
  final String type;
  final String md5;
  final String bucket;
  final int length;
  final bool sync;

  const FileInfoRepo(
      {
      // required this.id,
      required this.name,
      required this.path,
      required this.type,
      required this.md5,
      required this.bucket,
      required this.length,
      required this.sync});

  FileInfoRepo.fromMap(Map<String, dynamic> file)
      // : id = file["id"],
      : name = file["name"],
        path = file["path"],
        type = file["type"],
        md5 = file["md5"],
        bucket = file["bucket"],
        length = file["length"],
        sync = file["sync"] == 0 ? false : true;

  Map<String, Object?> toMap() {
    return {
      // 'id': id,
      'name': name,
      'path': path,
      'type': type,
      'md5': md5,
      'bucket': bucket,
      'length': length,
      'sync': sync
    };
  }

  @override
  String toString() {
    return 'FileInfoRepo{name:$name,path:$path,type:$type,md5:$md5,bucket:$bucket,length:$length,sync:$sync}';
  }
}
