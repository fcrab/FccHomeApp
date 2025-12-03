import 'package:fcc_home/entity/upload_task.dart';
import 'package:fcc_home/repo/file_info_repo.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDBHelper {
  Database? db;

  final fileTable = "fileinfos";
  final taskTable = "upload_tasks";

  Future<void> initDB() async {
    db ??= await openDatabase(
        join(await getDatabasesPath(), 'local_album_database.db'),
        onCreate: (db, version) async {
      await db.execute(
          'CREATE TABLE $fileTable(id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT,path TEXT,type TEXT,md5 TEXT,bucket TEXT,length INTEGER,sync BOOLEAN)');
      await _createTaskTable(db);
    }, onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 3) {
        await _createTaskTable(db);
      }
    }, version: 3);
  }

  Future<void> _createTaskTable(Database db) async {
    await db.execute('''
      CREATE TABLE $taskTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fileName TEXT,
        filePath TEXT,
        bucketName TEXT,
        md5 TEXT,
        fileSize INTEGER,
        status INTEGER,
        progress INTEGER,
        errorMessage TEXT,
        createTime INTEGER
      )
    ''');
  }

  // Upload Task Methods

  Future<int> insertTask(UploadTask task) async {
    if (db != null) {
      return await db!.insert(taskTable, task.toMap());
    }
    return -1;
  }

  Future<int> updateTask(UploadTask task) async {
    if (db != null && task.id != null) {
      return await db!.update(taskTable, task.toMap(),
          where: 'id = ?', whereArgs: [task.id]);
    }
    return -1;
  }

  Future<UploadTask?> getTaskByPath(String path) async {
    if (db != null) {
      List<Map<String, dynamic>> maps = await db!.query(taskTable,
          where: 'filePath = ?', whereArgs: [path]);
      if (maps.isNotEmpty) {
        return UploadTask.fromMap(maps.first);
      }
    }
    return null;
  }

  Future<List<UploadTask>> getAllTasks() async {
    if (db != null) {
      List<Map<String, dynamic>> maps = await db!.query(taskTable, orderBy: "createTime DESC");
      return List.generate(maps.length, (i) {
        return UploadTask.fromMap(maps[i]);
      });
    }
    return [];
  }

  Future<List<UploadTask>> getPendingTasks() async {
    if (db != null) {
      List<Map<String, dynamic>> maps = await db!.query(taskTable,
          where: 'status IN (?, ?)',
          whereArgs: [UploadTask.STATUS_PENDING, UploadTask.STATUS_UPLOADING],
          orderBy: "createTime ASC");
      return List.generate(maps.length, (i) {
        return UploadTask.fromMap(maps[i]);
      });
    }
    return [];
  }

  Future<int> deleteTask(int id) async {
    if (db != null) {
      return await db!.delete(taskTable, where: 'id = ?', whereArgs: [id]);
    }
    return -1;
  }


  Future<int> insertFileInfo(FileInfoRepo fileInfo) async {
    if (db != null) {
      int result = await db!.insert(fileTable, fileInfo.toMap());
      return result;
    } else {
      return -1;
    }
  }

  Future<int> updateFileInfos(List<FileInfoRepo> files) async {
    for (var info in files) {
      await db!.update(fileTable, info.toMap(),
          where: 'path = ?', whereArgs: [info.path]);
      return 1;
    }
    return -1;
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
