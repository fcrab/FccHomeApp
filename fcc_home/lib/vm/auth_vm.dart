import 'dart:convert';

import 'package:fcc_home/entity/login_info.dart';

import '../home_global.dart';
import '../net_client.dart';

class AuthVM {
  LoginInfo loginInfo = LoginInfo.info(name: "", password: "");

  // LoginInfo get loginInfo {
  //   return _loginInfo;
  // }

  var client = NetClient();

  void sendTest(String userName, String password) {
    // loginInfo = LoginInfo.test();
    // loginInfo.notifyListeners();
    print("vm test has been called");
    // loginInfo.testNoti();
    loginInfo.refreshData(LoginInfo.test());
  }

  // todo test
  Future<void> verifyLocal() async {
    await HomeGlobal.getLocalToken();
    if (HomeGlobal.token != "") {
      var info = LoginInfo.cache(id: HomeGlobal.token);
      HomeGlobal.saveAccess(info);
      loginInfo.refreshData(LoginInfo.cache(id: HomeGlobal.token));
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
