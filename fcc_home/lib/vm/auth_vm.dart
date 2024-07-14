import 'dart:convert';

import 'package:fcc_home/entity/login_info.dart';
import 'package:flutter/foundation.dart';

import '../home_global.dart';
import '../net_client.dart';

class AuthVM {
  LoginInfo loginInfo = LoginInfo.info(name: "", password: "");

  // LoginInfo get loginInfo {
  //   return _loginInfo;
  // }

  var client = NetClient();

  Future<void> sendTest(String userName, String password) async {
    // loginInfo = LoginInfo.test();
    // loginInfo.notifyListeners();
    print("vm test has been called");
    // loginInfo.testNoti();
    loginInfo.refreshData(LoginInfo.test());
  }

  // todo test
  Future<void> verifyLocal() async {
    await HomeGlobal.getLocalToken();
    print("login info : ${HomeGlobal.token}");
    if (HomeGlobal.token != "") {
      //todo 获取完整信息
      var info = LoginInfo.cache(id: HomeGlobal.token);
      HomeGlobal.saveAccess(info);
      await HomeGlobal.getAccessInfo();
      // loginInfo.refreshData(LoginInfo.cache(id: HomeGlobal.token));
    }
  }

  Future<void> sendLogin(userName, password) async {
    try {
      var loginStr = await client.postLogin(userName, password);
      if (loginStr != null) {
        Map<String, dynamic> jsonObj = json.decode(loginStr);
        var info = LoginInfo.fromJson(jsonObj);
        HomeGlobal.saveAccessInfo(loginStr);
        HomeGlobal.saveAccessToken(info.id);
        loginInfo.refreshData(info);
      }
      //test
      // loginInfo.refreshData(LoginInfo.test());
      // HomeGlobal.saveAccessToken(loginInfo.id);
    } catch (exp) {
      print(exp);
    } finally {
      // _progressDialog.hide();
    }
  }

  Future<void> sendLogout() async {
    try {
      if (HomeGlobal.token.isNotEmpty) {
        // var logoutStr = await client.postLogout(HomeGlobal.token);
        await HomeGlobal.clean();
      }
    } catch (exp) {
      if (kDebugMode) {
        print(exp);
      }
    }
  }

  Future<void> sendRegister(userName, password) async {
    try {
      // _progressDialog.show(message: "请稍后");
      // var loginStr =
      // await client.postLogin(userName, password);
      var userMap = await client.register(userName, password);
      if (userMap != null) {
        Map<String, dynamic> jsonObj = json.decode(userMap);
        var info = LoginInfo.fromJson(jsonObj);
        HomeGlobal.saveAccessToken(info.id);
        loginInfo.refreshData(info);
      }

      // if (tokenMap != null) {
      //   Map<String, dynamic> jsonObj = json.decode(tokenMap);
      //   HomeGlobal.saveAccessToken(jsonObj['access']);
      // }

    } catch (exp) {
      print(exp);
    } finally {
      // _progressDialog.hide();
    }
  }
}
