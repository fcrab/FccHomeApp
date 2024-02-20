import 'dart:io';

import 'package:crypto/crypto.dart';

//只能用于小文件，并且会把文件都放进内存里，最好还是计算后把数据存起来
Future<String> getFileHash(String path) async {
  final file = File(path);
  // final fileLength = file.lengthSync();

  final bytes = file.readAsBytesSync().buffer.asUint8List();
  final hash = md5.convert(bytes.buffer.asUint8List()).toString();
  return hash;
}
