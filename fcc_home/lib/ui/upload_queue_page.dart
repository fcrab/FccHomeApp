import 'package:fcc_home/entity/upload_task.dart';
import 'package:fcc_home/service/upload_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UploadQueuePage extends StatefulWidget {
  const UploadQueuePage({Key? key}) : super(key: key);

  @override
  State<UploadQueuePage> createState() => _UploadQueuePageState();
}

class _UploadQueuePageState extends State<UploadQueuePage> {
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    // Ensure service is initialized or refresh data
    UploadService().init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("提交队列"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              // Clear completed tasks? Or all?
            },
          )
        ],
      ),
      body: ChangeNotifierProvider.value(
        value: UploadService(),
        child: Consumer<UploadService>(
          builder: (context, service, child) {
            bool hasFailedTasks =
                service.tasks.any((t) => t.status == UploadTask.STATUS_FAILED);

            return Stack(
              children: [
                if (service.tasks.isEmpty)
                  const Center(child: Text("暂无上传任务"))
                else
                  ListView.builder(
                    padding: const EdgeInsets.only(top: 80),
                    // Make space for the button
                    itemCount: service.tasks.length,
                    itemBuilder: (context, index) {
                      final task = service.tasks[index];
                      return _buildTaskItem(task, service);
                    },
                  ),
                if (hasFailedTasks)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: FloatingActionButton.extended(
                      onPressed: _isRetrying
                          ? null
                          : () async {
                              setState(() {
                                _isRetrying = true;
                              });
                              await service.retryAllFailed();
                              // Prevent rapid clicks
                              await Future.delayed(const Duration(seconds: 2));
                              if (mounted) {
                                setState(() {
                                  _isRetrying = false;
                                });
                              }
                            },
                      icon: _isRetrying
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.refresh),
                      label: const Text("重试所有失败"),
                      backgroundColor: Colors.redAccent,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTaskItem(UploadTask task, UploadService service) {
    String statusText;
    Color statusColor;
    IconData statusIcon;

    switch (task.status) {
      case UploadTask.STATUS_PENDING:
        statusText = "等待中";
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        break;
      case UploadTask.STATUS_UPLOADING:
        statusText = "上传中";
        statusColor = Colors.blue;
        statusIcon = Icons.cloud_upload;
        break;
      case UploadTask.STATUS_COMPLETED:
        statusText = "已完成";
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case UploadTask.STATUS_FAILED:
        statusText = "失败";
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      case UploadTask.STATUS_DEAD:
        statusText = "已放弃";
        statusColor = Colors.brown;
        statusIcon = Icons.cancel;
        break;
      case UploadTask.STATUS_PAUSED:
        statusText = "已暂停";
        statusColor = Colors.orangeAccent;
        statusIcon = Icons.pause_circle;
        break;
      default:
        statusText = "未知";
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: Icon(statusIcon, color: statusColor, size: 32),
        title: Text(task.fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (task.status == UploadTask.STATUS_FAILED ||
                task.status == UploadTask.STATUS_DEAD)
              Text("错误: ${task.errorMessage ?? '未知错误'}",
                  style: const TextStyle(color: Colors.red, fontSize: 12)),
            if (task.status == UploadTask.STATUS_UPLOADING)
              LinearProgressIndicator(value: task.progress / 100),
            if (task.status != UploadTask.STATUS_UPLOADING &&
                task.status != UploadTask.STATUS_FAILED &&
                task.status != UploadTask.STATUS_DEAD)
              Text("大小: ${_formatFileSize(task.fileSize)}", style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(statusText, style: TextStyle(color: statusColor, fontSize: 12)),
                if (task.status == UploadTask.STATUS_UPLOADING)
                  Text("${task.progress}%", style: const TextStyle(fontSize: 12)),
              ],
            )
          ],
        ),
        trailing: _buildTrailingAction(task, service),
      ),
    );
  }

  Widget? _buildTrailingAction(UploadTask task, UploadService service) {
    if (task.status == UploadTask.STATUS_FAILED ||
        task.status == UploadTask.STATUS_DEAD) {
      return IconButton(
        icon: const Icon(Icons.refresh),
        onPressed: () => service.retryTask(task),
      );
    } else if (task.status == UploadTask.STATUS_PAUSED) {
      return IconButton(
        icon: const Icon(Icons.play_arrow),
        onPressed: () => service.resumeTask(task),
      );
    } else if (task.status == UploadTask.STATUS_PENDING ||
        task.status == UploadTask.STATUS_UPLOADING) {
      return IconButton(
        icon: const Icon(Icons.pause),
        onPressed: () => service.pauseTask(task),
      );
    }
    return null;
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (bytes.toString().length / 3).floor();
    if (i >= suffixes.length) i = suffixes.length - 1;
    return ((bytes / (1024 * i)).toStringAsFixed(2)) + ' ' + suffixes[i];
  }
}
