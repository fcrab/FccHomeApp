import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GridPrefsVM extends ChangeNotifier {
  static const String _key = 'grid_crossAxisCount';
  int _crossAxisCount = 4;
  SharedPreferences? _prefs;

  int get crossAxisCount => _crossAxisCount;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _crossAxisCount = _prefs?.getInt(_key) ?? 4;
    notifyListeners();
  }

  void setCount(int count) {
    _crossAxisCount = count;
    _prefs?.setInt(_key, count);
    notifyListeners();
  }
}
