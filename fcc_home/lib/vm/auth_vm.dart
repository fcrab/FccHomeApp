import 'dart:convert';

import 'package:fcc_home/entity/login_info.dart';
import 'package:flutter/material.dart';

import '../home_global.dart';
import '../net_client.dart';

class AuthVM with ChangeNotifier {
  LoginInfo _loginInfo = LoginInfo.info(name: "", password: "");

  LoginInfo get loginInfo {
    return _loginInfo;
  }

  var client = NetClient();

  Future<void> sendLogin(userName, password) async {
    try {
      // _progressDialog.show(message: "请稍后");
      var loginStr = await client.postLogin(userName, password);
      if (loginStr != null) {
        Map<String, dynamic> jsonObj = json.decode(loginStr);
        _loginInfo = LoginInfo.fromJson(jsonObj);
        if (_loginInfo != null) {
          HomeGlobal.saveAccessToken(loginInfo!.id);
        }

        notifyListeners();
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
