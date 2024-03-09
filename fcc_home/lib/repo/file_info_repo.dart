// docs https://docs.flutter.dev/cookbook/persistence/sqlite
class FileInfoRepo {
  final int id;
  final String name;
  final String path;
  final String type;
  final String md5;
  final int length;

  const FileInfoRepo({required this.id,
    required this.name,
      required this.path,
      required this.type,
      required this.md5,
      required this.length});

  FileInfoRepo.fromMap(Map<String, dynamic> file)
      : id = file["id"],
        name = file["name"],
        path = file["path"],
        type = file["type"],
        md5 = file["md5"],
        length = file["length"];

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'type': type,
      'md5': md5,
      'length': length
    };
  }

  @override
  String toString() {
    return 'FileInfoRepo{id:$id,name:$name,path:$path,type:$type,md5:$md5,length:$length}';
  }
}
