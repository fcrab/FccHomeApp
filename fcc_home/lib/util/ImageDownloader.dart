import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ImageDownloader {
  final Dio dio = Dio();

  Future<String> downloadImage(String imageUrl, String name) async {
    //todo check permissions

    try {
      final dic = await getExternalStorageDirectory();
      final filePath = '${dic?.path}/downloaded/$name';
      print('download path: $filePath');

      await dio.download(imageUrl, filePath);

      return filePath;
    } catch (exp) {
      print(exp);
    }

    return '';
  }

  Future<void> sharePics(String imageUrl, String name) async {
    final path = await downloadImage(imageUrl, name);
    if (path.isNotEmpty) {
      final result = await Share.shareXFiles([XFile(path)], text: name);

      if (result.status == ShareResultStatus.success) {
        print('share pics successful');
      }
    }
  }
}
