import 'package:fcc_home/repo/file_info_repo.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDBHelper {
  Database? db;

  final fileTable = "fileinfos";

  Future<void> initDB() async {
    db ??= await openDatabase(
        join(await getDatabasesPath(), 'local_album_database.db'),
        onCreate: (db, version) {
      return db.execute(
          'CREATE TABLE $fileTable(id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT,path TEXT,type TEXT,md5 TEXT,length INTEGER,sync BOOLEAN)');
    }, version: 2);
  }

  Future<int> insertFileInfo(FileInfoRepo fileInfo) async {
    if (db != null) {
      int result = await db!.insert(fileTable, fileInfo.toMap());
      return result;
    } else {
      return -1;
    }
  }

  Future<List<FileInfoRepo>> retrieveFiles(List<String> md5) async {
    if (db != null) {
      List<Map<String, Object?>> result =
          await db!.rawQuery("SELECT * FROM $fileTable where md5 in ?", [md5]);
      return result.map((e) => FileInfoRepo.fromMap(e)).toList();
    } else {
      return [];
    }
  }

  Future<FileInfoRepo?> retrieveFileByPath(String uri) async {
    if (db != null) {
      List<Map<String, Object?>> result =
          // await db.rawQuery("SELECT * FROM $fileTable where path in ?", [uri]);
          await db!.query(fileTable, where: "path = ?", whereArgs: [uri]);
      if (result.isNotEmpty) {
        return FileInfoRepo.fromMap(result[0]);
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  Future<List<FileInfoRepo>> retrieveFilesByPath(List<String> uri) async {
    if (db != null) {
      List<Map<String, Object?>> result =
          // await db.rawQuery("SELECT * FROM $fileTable where path in ?", [uri]);
          await db!.query(fileTable,
              where: "path IN (${List.filled(uri.length, '?').join(',')})",
              whereArgs: uri);

      return result.map((e) => FileInfoRepo.fromMap(e)).toList();
    } else {
      return [];
    }
  }
}
