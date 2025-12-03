import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:fcc_home/entity/upload_task.dart';
import 'package:fcc_home/home_global.dart';
import 'package:fcc_home/repo/local_db_helper.dart';
import 'package:flutter/foundation.dart';

class UploadService with ChangeNotifier {
  static final UploadService _instance = UploadService._internal();

  factory UploadService() => _instance;

  UploadService._internal();

  final LocalDBHelper _dbHelper = LocalDBHelper();
  final Dio _dio = Dio();
  bool _isProcessing = false;
  List<UploadTask> _tasks = [];

  List<UploadTask> get tasks => _tasks;

  // Constants
  static const String _baseUrl = "http://192.168.31.206:8080/"; // Should match NetClient
  static const String _uploadUrl = "files/upload";

  Future<void> init() async {
    _setupDio();
    await _dbHelper.initDB();
    await _loadTasks();
    _processQueue();
  }

  void _setupDio() {
    _dio.options.connectTimeout = const Duration(seconds: 60);
    _dio.options.receiveTimeout = const Duration(seconds: 60);
    _dio.options.contentType = Headers.jsonContentType;
    (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return null;
    };
  }

  Future<void> _loadTasks() async {
    _tasks = await _dbHelper.getAllTasks();
    notifyListeners();
  }

  Future<void> addTask(String filePath, String fileName, String md5, String bucketName, int fileSize) async {
    // Check if already exists
    var existing = await _dbHelper.getTaskByPath(filePath);
    if (existing != null) {
      if (existing.status == UploadTask.STATUS_COMPLETED) {
        return; // Already uploaded
      }
      // If failed or pending, maybe reset?
      if (existing.status == UploadTask.STATUS_FAILED) {
        existing.status = UploadTask.STATUS_PENDING;
        existing.errorMessage = null;
        existing.progress = 0;
        await _dbHelper.updateTask(existing);
      }
    } else {
      var task = UploadTask(
        fileName: fileName,
        filePath: filePath,
        bucketName: bucketName,
        md5: md5,
        fileSize: fileSize,
        createTime: DateTime.now().millisecondsSinceEpoch,
        status: UploadTask.STATUS_PENDING,
      );
      await _dbHelper.insertTask(task);
    }
    await _loadTasks();
    _processQueue();
  }

  Future<void> retryTask(UploadTask task) async {
    task.status = UploadTask.STATUS_PENDING;
    task.errorMessage = null;
    task.progress = 0;
    await _dbHelper.updateTask(task);
    await _loadTasks();
    _processQueue();
  }

  Future<void> deleteTask(UploadTask task) async {
    if (task.id != null) {
      await _dbHelper.deleteTask(task.id!);
      await _loadTasks();
    }
  }

  Future<void> _processQueue() async {
    if (_isProcessing) return;

    var pending = await _dbHelper.getPendingTasks();
    if (pending.isEmpty) return;

    _isProcessing = true;

    for (var task in pending) {
      // Re-check status in case it was cancelled or changed
      var currentTask = _tasks.firstWhere((t) => t.id == task.id, orElse: () => task);
      if (currentTask.status != UploadTask.STATUS_PENDING) continue;

      // Check if file exists
      File file = File(task.filePath);
      if (!file.existsSync()) {
         task.status = UploadTask.STATUS_FAILED;
         task.errorMessage = "File not found";
         await _updateTaskStatus(task);
         continue;
      }

      try {
        task.status = UploadTask.STATUS_UPLOADING;
        await _updateTaskStatus(task);

        await _uploadFile(task);

        task.status = UploadTask.STATUS_COMPLETED;
        task.progress = 100;
        await _updateTaskStatus(task);
      } catch (e) {
        print("Upload failed: $e");
        task.status = UploadTask.STATUS_FAILED;
        task.errorMessage = e.toString();
        await _updateTaskStatus(task);
      }
    }

    _isProcessing = false;
    // Check again if new tasks were added
    _processQueue();
  }

  Future<void> _updateTaskStatus(UploadTask task) async {
    await _dbHelper.updateTask(task);
    // Update local list in memory to reflect changes in UI immediately
    var index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      notifyListeners();
    } else {
       await _loadTasks();
    }
  }

  Future<void> _uploadFile(UploadTask task) async {
    String token = HomeGlobal.token; // Assuming token is available
    
    FormData data = FormData.fromMap({
      "img": await MultipartFile.fromFile(task.filePath, filename: task.fileName),
      "name": task.fileName,
      "bucket": task.bucketName,
      "user_id": token,
      "md5": task.md5
    });

    await _dio.post(
      _baseUrl + _uploadUrl,
      data: data,
      onSendProgress: (int sent, int total) {
        if (total > 0) {
          int progress = ((sent / total) * 100).toInt();
          if (progress > task.progress) {
             task.progress = progress;
             // Optimize DB updates: only update DB every 10% or so to avoid thrashing?
             // For now, just notify listeners, update DB less frequently if needed.
             // We update memory immediately.
             var index = _tasks.indexWhere((t) => t.id == task.id);
             if (index != -1) {
               _tasks[index].progress = progress;
               notifyListeners();
             }
          }
        }
      },
    );
    
    // Ensure 100% at end
    task.progress = 100;
  }
}
