class UploadTask {
  static const int STATUS_PENDING = 0;
  static const int STATUS_UPLOADING = 1;
  static const int STATUS_COMPLETED = 2;
  static const int STATUS_FAILED = 3;
  static const int STATUS_PAUSED = 4;
  static const int STATUS_DEAD = 5;

  int? id;
  String fileName;
  String filePath;
  String bucketName;
  String md5;
  int fileSize;
  int status;
  int progress;
  String? errorMessage;
  int createTime;
  int retryCount;

  UploadTask({
    this.id,
    required this.fileName,
    required this.filePath,
    required this.bucketName,
    required this.md5,
    this.fileSize = 0,
    this.status = STATUS_PENDING,
    this.progress = 0,
    this.errorMessage,
    required this.createTime,
    this.retryCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fileName': fileName,
      'filePath': filePath,
      'bucketName': bucketName,
      'md5': md5,
      'fileSize': fileSize,
      'status': status,
      'progress': progress,
      'errorMessage': errorMessage,
      'createTime': createTime,
      'retryCount': retryCount,
    };
  }

  factory UploadTask.fromMap(Map<String, dynamic> map) {
    return UploadTask(
      id: map['id'],
      fileName: map['fileName'],
      filePath: map['filePath'],
      bucketName: map['bucketName'],
      md5: map['md5'],
      fileSize: map['fileSize'] ?? 0,
      status: map['status'] ?? STATUS_PENDING,
      progress: map['progress'] ?? 0,
      errorMessage: map['errorMessage'],
      createTime: map['createTime'] ?? DateTime.now().millisecondsSinceEpoch,
      retryCount: map['retryCount'] ?? 0,
    );
  }
}
