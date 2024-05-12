import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

class NetClient {
  Dio dio = Dio();

  NetClient() : super() {
    dio.options.connectTimeout = const Duration(seconds: 20);
    dio.options.receiveTimeout = const Duration(seconds: 20);
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
  //local
  // String baseUrl = "http://192.168.31.193:8080/";

  String baseUrl = "http://192.168.31.206:8080/";

  // 注册
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

  //登录
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

  //刷新token
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

  //获取云端照片
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

  //获取云端目录
  Future<String?> getServerDirList(String token, int parent) async {
    String dirListUrl = "folder/expand";
    try {
      var map = {'userId': token, 'folderId': parent};
      print("get Server Dir :$map");
      var response = await dio.get(baseUrl + dirListUrl, queryParameters: map);
      return parseResult(response);
    } catch (exp) {
      print(exp);
    }
    return null;
  }

  //检查文件同步状态
  Future<String?> checkFilesExist(List<String> md5s,String token) async{
    String checkUrl = "files/checkFiles";
    try{
      var map = {'user': token, 'files': md5s};
      // print("checkFiles data\n$map");
      print("checkFiles data");
      var response = await dio.post(baseUrl + checkUrl, queryParameters: map);
      return parseResult(response);
    }catch(exp){
      print(exp);
    }
    return null;
  }

  //上传图片
  Future<String?> uploadLocalFile(String name,String path,String token,String md5) async{
    String uploadUrl = "files/upload";
    try{
      FormData data = FormData.fromMap({
        "img":
        await MultipartFile.fromFile(path,filename: name),
        "name":name,
        "user_id":token,
        "md5":md5
      });
      var response = await dio.post(baseUrl+uploadUrl,data:data);
      return parseResult(response);
    }catch(exp){
      print(exp);
    }
    return null;
  }

  //基础解析
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
