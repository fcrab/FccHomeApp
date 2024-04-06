//check file exist in server before upload
// Future<void> checkFileSyncTop(List<dynamic> args) async {
//   var client = NetClient();
//   List<String> md5s = [];
//   List<FileInfoRepo> entries = args[1];
//   print("file numbers ${entries.length}");
//   var map = {};
//   for (var entity in entries) {
//     //todo select from db
//     if (entity.md5 != "") {
//       md5s.add(entity.md5);
//       map[entity.md5] = entity.name;
//     }
//   }
//
//   String? result = await client.checkFilesExist(md5s, HomeGlobal.token);
//   if (result != null) {
//     print("checkFileResult: $result");
//     List<dynamic> unSyncMd5s = json.decode(result);
//     var resultMap = {};
//     for (var md5 in unSyncMd5s) {
//       resultMap[map[md5]] = md5;
//     }
//     // mineEntries.refreshSyncState(unSyncMd5s);
//     Isolate.exit(args[0], resultMap);
//   } else {
//     Isolate.exit(args[0], []);
//   }
// }

void test() {
  // 1
  // final resultPort = ReceivePort();
  // 2
  // SendPort port = resultPort.sendPort;
  // 3
  // var isolate =
  //     // await Isolate.spawn(checkFileSyncTop, [port, mineEntries.syncEntries]);
  //     await Isolate.spawn(checkFileSyncTop, [port, localUploadInfos,HomeGlobal.token]);
  // // 4
  // Map result = await resultPort.first;
}
