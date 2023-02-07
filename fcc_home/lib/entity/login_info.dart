//{"id":6,"name":"at2","password":"0000","salt":"","email":"0000at1@ggg.com","phoneNumber":"00001","status":1,"lastUpdateTime":"Jan 5, 2023, 12:00:00 AM"}

import 'dart:convert';

class LoginInfo {
  final String id;
  final String name;
  final String password;
  final String salt;
  final String email;
  final String phoneNumber;
  final int status;
  final String lastUpdateTime;

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

  String toJson() {
    return json.encode(this);
  }

  factory LoginInfo.fromJson(Map<String, dynamic> json) {
    return LoginInfo(
        id: json['id'] as String,
        name: json['name'] as String,
        password: (json['password'] ?? "") as String,
        salt: json['salt'] as String,
        email: json['email'] as String,
        phoneNumber: json['phoneNumber'] as String,
        status: json['status'] as int,
        lastUpdateTime: json['lastUpdateTime'] as String);
  }
}
