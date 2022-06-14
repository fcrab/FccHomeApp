import 'package:shared_preferences/shared_preferences.dart';

class HomeGlobal {
  static String token = "";

  static saveAccessToken(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("token", value);
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
