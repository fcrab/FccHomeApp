import 'package:flutter/material.dart';

class MediaServerVM with ChangeNotifier {
  Future<void> fetchPicsData() async {
    notifyListeners();
  }
}
