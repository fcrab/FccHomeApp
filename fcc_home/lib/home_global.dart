import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'entity/login_info.dart';

class HomeGlobal {
  static LoginInfo? loginInfo;

  static String token = "";

  static const platform = MethodChannel("com.crabfibber.fcc_home/event");

  static saveAccessInfo(String value) async {
    saveInfo("user", value);
    Map<String, dynamic> jsonObj = json.decode(value);
    loginInfo = LoginInfo.fromJson(jsonObj);
  }

  static saveAccess(LoginInfo info) async {
    loginInfo = info;
  }

  static saveAccessToken(String value) async {
    saveInfo("token", value);
    await getLocalToken();
  }

  static saveRefreshToken(String value) async {
    saveInfo("refresh", value);
  }

  static getAccessInfo() async {
    var loginInfoStr = await getLocalInfo("user");
    if (loginInfoStr != null) {
      Map<String, dynamic> jsonObj = json.decode(loginInfoStr);
      loginInfo = LoginInfo.fromJson(jsonObj);
    }
  }

  static getLocalToken() async {
    String? result = await getLocalInfo("token");
    if (result != null) {
      token = result;
    }
  }

  static saveInfo(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  static Future<String?> getLocalInfo(String key) async {
    String? result = "";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    result = prefs.getString(key);
    return result;
  }

  static String getUsername() {
    return HomeGlobal.loginInfo != null ? HomeGlobal.loginInfo!.name : "";
  }

  static clean() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("token");
    prefs.remove("refresh");
    prefs.remove("user");
    token = "";
    loginInfo = null;
  }
}
