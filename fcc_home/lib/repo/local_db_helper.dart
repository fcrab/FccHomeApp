import 'package:fcc_home/repo/file_info_repo.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDBHelper {
  late Database db;

  final fileTable = "fileinfos";

  Future<void> initDB() async {
    db = await openDatabase(
        join(await getDatabasesPath(), 'local_album_database.db'),
        onCreate: (db, version) {
      return db.execute(
          'CREATE TABLE $fileTable(id INTEGER PRIMARY KEY,name TEXT,path TEXT,type TEXT,md5 TEXT,length INTEGER)');
    }, version: 1);
  }

  Future<int> insertFileInfo(FileInfoRepo fileInfo) async {
    int result = await db.insert(fileTable, fileInfo.toMap());
    return result;
  }

  Future<List<FileInfoRepo>> retrieveFiles(List<String> md5) async {
    List<Map<String, Object?>> result =
        await db.rawQuery("SELECT * FROM $fileTable where md5 in ?", md5);
    return result.map((e) => FileInfoRepo.fromMap(e)).toList();
  }
}
