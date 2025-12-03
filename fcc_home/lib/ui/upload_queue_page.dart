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
            if (service.tasks.isEmpty) {
              return const Center(child: Text("暂无上传任务"));
            }
            return ListView.builder(
              itemCount: service.tasks.length,
              itemBuilder: (context, index) {
                final task = service.tasks[index];
                return _buildTaskItem(task, service);
              },
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
            if (task.status == UploadTask.STATUS_FAILED)
              Text("错误: ${task.errorMessage}", style: const TextStyle(color: Colors.red, fontSize: 12)),
            if (task.status == UploadTask.STATUS_UPLOADING)
              LinearProgressIndicator(value: task.progress / 100),
            if (task.status != UploadTask.STATUS_UPLOADING && task.status != UploadTask.STATUS_FAILED)
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
        trailing: task.status == UploadTask.STATUS_FAILED
            ? IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  service.retryTask(task);
                },
              )
            : null,
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (bytes.toString().length / 3).floor();
    return ((bytes / (1024 * i)).toStringAsFixed(2)) + ' ' + suffixes[i]; // Simplified logic
  }
}
