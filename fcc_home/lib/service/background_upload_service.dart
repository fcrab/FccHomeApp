import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:fcc_home/entity/upload_task.dart';
import 'package:fcc_home/repo/local_db_helper.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundUploadService {
  static const String notificationChannelId = 'upload_channel';
  static const int notificationId = 888;

  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      notificationChannelId,
      'Upload Service',
      description: 'Background file upload service',
      importance: Importance.low,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: notificationChannelId,
        initialNotificationTitle: 'Upload Service',
        initialNotificationContent: 'Initializing...',
        foregroundServiceNotificationId: notificationId,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    return true;
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    final LocalDBHelper dbHelper = LocalDBHelper();
    await dbHelper.initDB();

    final Dio dio = Dio();
    _setupDio(dio);

    // Listen for stop event
    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    // Listen for new tasks signal
    service.on('checkQueue').listen((event) {
      _processQueue(service, dbHelper, dio, flutterLocalNotificationsPlugin);
    });

    // Initial check
    _processQueue(service, dbHelper, dio, flutterLocalNotificationsPlugin);

    // Periodic check as a safety net (every 1 minute)
    Timer.periodic(const Duration(minutes: 1), (timer) {
      _processQueue(service, dbHelper, dio, flutterLocalNotificationsPlugin);
    });
  }

  static bool _isProcessing = false;

  static Future<void> _processQueue(
      ServiceInstance service,
      LocalDBHelper dbHelper,
      Dio dio,
      FlutterLocalNotificationsPlugin notifications) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      var pending = await dbHelper.getPendingTasks();
      if (pending.isEmpty) {
        await _updateNotification(notifications, "No pending tasks", "");
        _isProcessing = false;
        return;
      }

      await _updateNotification(
          notifications, "Uploading...", "${pending.length} files remaining");

      for (var task in pending) {
        // Re-fetch to ensure status hasn't changed
        var currentTask = await dbHelper.getTaskByPath(task.filePath);
        if (currentTask == null ||
            currentTask.status != UploadTask.STATUS_PENDING) {
          continue;
        }

        File file = File(task.filePath);
        if (!file.existsSync()) {
          task.status = UploadTask.STATUS_FAILED;
          task.errorMessage = "File not found";
          await dbHelper.updateTask(task);
          continue;
        }

        task.status = UploadTask.STATUS_UPLOADING;
        await dbHelper.updateTask(task);

        // Notify UI
        service.invoke('update', {'taskId': task.id});

        try {
          await _uploadFile(task, dio, (progress) {
            // Update notification progress occasionally?
            // Doing it too often might lag
          });

          task.status = UploadTask.STATUS_COMPLETED;
          task.progress = 100;
          await dbHelper.updateTask(task);
        } catch (e) {
          print("Background upload failed: $e");

          bool isNetworkError = false;
          if (e is DioException) {
            if (e.type == DioExceptionType.connectionTimeout ||
                e.type == DioExceptionType.receiveTimeout ||
                e.type == DioExceptionType.sendTimeout ||
                e.type == DioExceptionType.connectionError ||
                e.type == DioExceptionType.unknown) {
              // Unknown often covers socket exceptions
              isNetworkError = true;
            }
          }

          if (isNetworkError) {
            task.status = UploadTask.STATUS_PAUSED;
            task.errorMessage = "Network error: ${e.toString()}";
            await _updateNotification(
                notifications, "Upload Paused", "Network error occurred");
          } else {
            task.status = UploadTask.STATUS_FAILED;
            task.errorMessage = e.toString();

            if (task.retryCount >= 3) {
              task.status = UploadTask.STATUS_DEAD;
              task.errorMessage = "Max retries reached: ${e.toString()}";
            }
          }

          await dbHelper.updateTask(task);
        }

        // Notify UI
        service.invoke('update', {'taskId': task.id});

        await _updateNotification(notifications, "Uploading...",
            "${pending.length - 1} files remaining");
      }
    } catch (e) {
      print("Queue processing error: $e");
    } finally {
      _isProcessing = false;
      // Check again
      var pending = await dbHelper.getPendingTasks();
      if (pending.isNotEmpty) {
        _processQueue(service, dbHelper, dio, notifications);
      } else {
        await _updateNotification(
            notifications, "Upload Service", "All tasks completed");
      }
    }
  }

  static Future<void> _uploadFile(
      UploadTask task, Dio dio, Function(int) onProgress) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token") ?? "";

    if (token.isEmpty) {
      throw Exception("No token found");
    }

    // URL constants
    const String _baseUrl = "http://192.168.31.206:8080/";
    const String _uploadUrl = "files/upload";

    FormData data = FormData.fromMap({
      "img":
          await MultipartFile.fromFile(task.filePath, filename: task.fileName),
      "name": task.fileName,
      "bucket": task.bucketName,
      "user_id": token,
      "md5": task.md5
    });

    await dio.post(
      _baseUrl + _uploadUrl,
      data: data,
      onSendProgress: (int sent, int total) {
        if (total > 0) {
          int progress = ((sent / total) * 100).toInt();
          onProgress(progress);
        }
      },
    );
  }

  static void _setupDio(Dio dio) {
    dio.options.connectTimeout = const Duration(seconds: 60);
    dio.options.receiveTimeout = const Duration(seconds: 60);
    dio.options.contentType = Headers.jsonContentType;
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return null;
    };
  }

  static Future<void> _updateNotification(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
      String title,
      String content) async {
    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin.show(
        notificationId,
        title,
        content,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            notificationChannelId,
            'Upload Service',
            icon: 'ic_bg_service_small',
            // Make sure this icon exists or use default
            ongoing: true,
          ),
        ),
      );
    }
  }
}
