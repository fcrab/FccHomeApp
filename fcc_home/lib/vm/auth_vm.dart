import 'dart:convert';

import 'package:fcc_home/entity/login_info.dart';

import '../home_global.dart';
import '../net_client.dart';

class AuthVM {
  LoginInfo loginInfo = LoginInfo.info(name: "1122", password: "23212");

  // LoginInfo get loginInfo {
  //   return _loginInfo;
  // }

  var client = NetClient();

  void sendTest(String userName, String password) {
    // loginInfo = LoginInfo.test();
    // loginInfo.notifyListeners();
    loginInfo.testNoti();
  }

  Future<void> sendLogin(userName, password) async {
    try {
      // _progressDialog.show(message: "请稍后");
      var loginStr = await client.postLogin(userName, password);
      if (loginStr != null) {
        Map<String, dynamic> jsonObj = json.decode(loginStr);
        loginInfo = LoginInfo.fromJson(jsonObj);
        HomeGlobal.saveAccessToken(loginInfo.id);

        loginInfo.notifyListeners();
      }
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
      var tokenMap = await client.register(userName, password);
      if (tokenMap != null) {
        Map<String, dynamic> jsonObj = json.decode(tokenMap);
        HomeGlobal.saveAccessToken(jsonObj['access']);
        // HomeGlobal.saveRefreshToken(jsonObj['refresh']);
      }

      // if (loginStr != null) {
      //   Map<String, dynamic> jsonObj = json.decode(loginStr);
      //   _loginInfo = LoginInfo.fromJson(jsonObj);
      //   if(_loginInfo!=null){
      //     HomeGlobal.saveAccessToken(loginInfo!.id);
      //   }
      //
      //   notifyListeners();
      //
      // }
    } catch (exp) {
      print(exp);
    } finally {
      // _progressDialog.hide();
    }
  }
}
