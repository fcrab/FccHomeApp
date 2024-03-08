// docs https://docs.flutter.dev/cookbook/persistence/sqlite
class FileInfoRepo {
  final String name;
  final String path;
  final String type;
  final String md5;
  final int length;

  const FileInfoRepo(
      {required this.name,
      required this.path,
      required this.type,
      required this.md5,
      required this.length});
}
