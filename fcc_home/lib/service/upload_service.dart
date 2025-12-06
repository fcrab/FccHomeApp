import 'dart:async';
import 'dart:io';

import 'package:fcc_home/entity/upload_task.dart';
import 'package:fcc_home/repo/local_db_helper.dart';
import 'package:fcc_home/service/background_upload_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class UploadService with ChangeNotifier {
  static final UploadService _instance = UploadService._internal();

  factory UploadService() => _instance;

  UploadService._internal();

  final LocalDBHelper _dbHelper = LocalDBHelper();
  List<UploadTask> _tasks = [];

  List<UploadTask> get tasks => _tasks;

  Future<void> init() async {
    await _dbHelper.initDB();
    await _loadTasks();

    // Initialize Background Service
    await BackgroundUploadService.initializeService();
    final service = FlutterBackgroundService();

    // Start service if not running?
    // Actually initializeService configures it.
    // We should start it.
    if (!await service.isRunning()) {
      service.startService();
    }

    // Listen for updates from background service
    service.on('update').listen((event) {
      if (event != null && event.containsKey('taskId')) {
        // Refresh specific task or all tasks?
        // Refreshing all is safer for consistency but maybe slower.
        // Given list size won't be huge, let's reload.
        _loadTasks();
      }
    });
  }

  Future<void> _loadTasks() async {
    _tasks = await _dbHelper.getAllTasks();
    notifyListeners();
  }

  Future<void> addTask(String filePath, String fileName, String md5, String bucketName, int fileSize) async {
    var existing = await _dbHelper.getTaskByPath(filePath);
    if (existing != null) {
      if (existing.status == UploadTask.STATUS_COMPLETED) {
        return;
      }
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

    // Trigger background service
    FlutterBackgroundService().invoke("checkQueue");
  }

  Future<void> retryTask(UploadTask task) async {
    task.status = UploadTask.STATUS_PENDING;
    task.errorMessage = null;
    task.progress = 0;
    task.retryCount = (task.retryCount) + 1; // Increment retry count
    await _dbHelper.updateTask(task);
    await _loadTasks();

    FlutterBackgroundService().invoke("checkQueue");
  }

  Future<void> retryAllFailed() async {
    var failedTasks =
        _tasks.where((t) => t.status == UploadTask.STATUS_FAILED).toList();
    if (failedTasks.isEmpty) return;

    for (var task in failedTasks) {
      task.status = UploadTask.STATUS_PENDING;
      task.errorMessage = null;
      task.progress = 0;
      task.retryCount = (task.retryCount) + 1;
      await _dbHelper.updateTask(task);
    }
    await _loadTasks();

    FlutterBackgroundService().invoke("checkQueue");
  }

  Future<void> pauseTask(UploadTask task) async {
    task.status = UploadTask.STATUS_PAUSED;
    await _dbHelper.updateTask(task);
    await _loadTasks();
  }

  Future<void> resumeTask(UploadTask task) async {
    task.status = UploadTask.STATUS_PENDING;
    task.errorMessage = null;
    await _dbHelper.updateTask(task);
    await _loadTasks();
    FlutterBackgroundService().invoke("checkQueue");
  }

  Future<void> deleteTask(UploadTask task) async {
    if (task.id != null) {
      await _dbHelper.deleteTask(task.id!);
      await _loadTasks();
    }
  }

// Removed internal processing logic as it's moved to BackgroundUploadService
}
