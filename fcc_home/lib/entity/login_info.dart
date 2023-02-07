//{"id":6,"name":"at2","password":"0000","salt":"","email":"0000at1@ggg.com","phoneNumber":"00001","status":1,"lastUpdateTime":"Jan 5, 2023, 12:00:00 AM"}

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

  factory LoginInfo.fromJson(Map<String, dynamic> json) {
    return LoginInfo(
        id: json['id'] as String,
        name: json['id'] as String,
        password: json['id'] as String,
        salt: json['salt'] as String,
        email: json['id'] as String,
        phoneNumber: json['id'] as String,
        status: json['status'] as int,
        lastUpdateTime: json['id'] as String);
  }
}
