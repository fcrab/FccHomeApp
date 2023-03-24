import 'dart:convert';
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

  // String baseUrl = "http://172.16.73.222:8080/";
  String baseUrl = "http://172.16.0.18:8080/";

  Future<String?> register(String name, String psw) async {
    String authUrl = "auth/create";
    try {
      var map = {
        'name': name,
        'password': psw,
        'salt': '',
        'email': '',
        'phoneNumber': '',
        'status': 1,
        'createTime': '',
        'lastLoginTime': ''
      };

      var response = await dio.post(baseUrl + authUrl, data: map);
      print(response);
      return parseResult(response);
    } catch (exp) {
      print(exp);
    }

    return null;
  }

  Future<String?> postLogin(String user, String psw) async {
    String authUrl = "auth/login";
    try {
      var map = {'name': user, 'password': psw};
      var response = await dio.post(baseUrl + authUrl, data: map);
      print(response);
      return parseResult(response);
    } catch (exp) {
      print(exp);
    }

    return null;
  }

  Future<String?> refreshToken(String refreshToken) async {
    String tokenUrl = "token/refresh";
    try {
      var response = await dio.post(baseUrl + tokenUrl,
          options: Options(headers: {'Authorization': refreshToken}));

      return parseResult(response);
    } catch (exp) {
      print(exp);
    }
    return null;
  }

  Future<String?> getServerPicsList(String token, int dir, int? page) async {
    String picListUrl = "files/listByPage";
    try {
      var map = {'user': token, 'folder': dir, 'page': page ?? 0};
      // var response = await dio.post(baseUrl + picListUrl + "/" + dir);
      var response = await dio.get(baseUrl + picListUrl, queryParameters: map);
      return parseResult(response);
    } catch (exp) {
      print(exp);
    }
    return null;
  }

  Future<String?> getServerDirList(String token, String parent) async {
    String dirListUrl = "folder/list";
    try {
      var map = {'id': token, 'parent': parent};
      var response = await dio.get(baseUrl + dirListUrl, queryParameters: map);
      return parseResult(response);
    } catch (exp) {
      print(exp);
    }
    return null;
  }

  String? parseResult(Response response) {
    if (response.statusCode == 200) {
      print(response.data);
      late Map<String, dynamic> data;
      if (response.data is String) {
        data = json.decode(response.data);
      } else {
        data = response.data;
      }
      var result = data['result'];
      var content = jsonEncode(data['content']);
      if (result == true) {
        return content;
      } else {
        throw Exception(content);
      }
      // return response.data.toString();
    } else {
      throw Exception(response.statusCode);
    }
  }
}
