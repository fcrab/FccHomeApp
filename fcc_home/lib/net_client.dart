import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';

class NetClient {
  Dio dio = new Dio();

  NetClient() : super() {
    dio.options.connectTimeout = 10 * 1000;
    dio.options.receiveTimeout = 10 * 1000;
    dio.options.contentType = Headers.jsonContentType;
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      //绑定代理
      client.findProxy = (uri) {
        return 'DIRECT';
        // return 'DIRECT';
      };
      //忽略证书
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    };
  }

  String baseUrl = "http://127.0.0.1:8000/";

  Future<String?> postLogin(String user, String psw) async {
    String authUrl = "token/";
    try {
      var response = await dio
          .post(baseUrl + authUrl, data: {'username': user, 'password': psw});
      print(response);
      return parseResult(response);
    } catch (exp) {
      print(exp);
    }

    return null;
  }

  Future<String?> refreshToken(String refreshToken) async {
    String tokenUrl = "/token/refresh";
    try {
      var response = await dio.post(baseUrl + tokenUrl,
          options: Options(headers: {'Authorization': refreshToken}));

      return parseResult(response);
    } catch (exp) {
      print(exp);
    }
    return null;
  }

  Future<String?> getServerPicsList(String token, String dir) async {
    String picListUrl = "/filelist";
    try {
      var response = await dio.post(baseUrl + picListUrl + "/" + dir);
      return parseResult(response);
    } catch (exp) {
      print(exp);
    }
    return null;
  }

  Future<String?> getServerDirList(String token) async {
    String dirListUrl = "/dirlist";
    try {
      var response = await dio.post(baseUrl + dirListUrl + "/");
      return parseResult(response);
    } catch (exp) {
      print(exp);
    }
    return null;
  }

  String? parseResult(Response response) {
    if (response.statusCode == 200) {
      return response.data.toString();
    }
    return null;
  }
}
