
import 'dart:convert';

import 'package:flutter/material.dart';

class LoginInfo with ChangeNotifier {
  String id;
  String name;
  String password;
  String salt;
  String email;
  String phoneNumber;
  int status;
  String lastUpdateTime;

  LoginInfo(
      {required this.id,
      required this.name,
      required this.password,
      required this.salt,
      required this.email,
      required this.phoneNumber,
      required this.status,
      required this.lastUpdateTime});

  LoginInfo.info({
    this.id = '',
    this.email = '',
    this.salt = '',
    this.phoneNumber = '',
    this.status = 1,
    this.lastUpdateTime = '',
    required this.name,
    required this.password,
  });

  LoginInfo.test({
    this.id = '6',
    this.email = '',
    this.salt = '',
    this.phoneNumber = '',
    this.status = 1,
    this.lastUpdateTime = '',
    this.name = 'test1',
    this.password = 'test11',
  });

  void testNoti() {
    name = "aabcded";
    password = "aabcded";
    id = "aabcded";

    notifyListeners();
  }

  void refreshData(LoginInfo info) {
    id = info.id;
    name = info.name;
    password = info.password;
    salt = info.salt;
    email = info.email;
    phoneNumber = info.phoneNumber;
    status = info.status;
    lastUpdateTime = info.lastUpdateTime;
    notifyListeners();
  }

  String toJson() {
    return json.encode(this);
  }

  factory LoginInfo.fromJson(Map<String, dynamic> json) {
    return LoginInfo(
        id: (json['id'] as int).toString(),
        name: json['name'] as String,
        password: (json['password'] ?? "") as String,
        salt: json['salt'] as String,
        email: json['email'] as String,
        phoneNumber: json['phoneNumber'] as String,
        status: json['status'] as int,
        lastUpdateTime: json['lastUpdateTime'] as String);
  }
}
