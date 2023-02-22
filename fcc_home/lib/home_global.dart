import 'package:shared_preferences/shared_preferences.dart';

import 'entity/login_info.dart';

class HomeGlobal {
  static LoginInfo? loginInfo;

  static String token = "";

  static saveAccessToken(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("token", value);
    _getLocalToken();
  }

  static saveRefreshToken(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("refresh", value);
  }

  static _getLocalToken() async {
    String? result = "";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    result = prefs.getString("token");
    if (result != null) {
      token = result;
    }
  }
}
