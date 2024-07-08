import 'package:fcc_home/vm/auth_vm.dart';
import 'package:flutter/material.dart';

class PersonalCenter extends StatefulWidget {
  AuthVM vm = AuthVM();

  @override
  State<StatefulWidget> createState() {
    return PersonalCenterState();
  }
}

class PersonalCenterState extends State<PersonalCenter> {
  @override
  void initState() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("个人中心"),
        ),
        body: Center(
          child: Column(children: [
            Row(
              children: [
                const Text("账号"),
                Text(widget.vm.loginInfo.name),
              ],
            ),
            Row(
              children: [
                const Text("密码"),
                Text(widget.vm.loginInfo.password),
              ],
            ),
            const Text("账号密码"),
            TextButton(
                onPressed: () {
                  widget.vm
                      .sendLogout()
                      .then((value) => {Navigator.pushNamed(context, "/")});
                  // widget.register(authNameCtrl.text, authPswCtrl.text);
                  // execute(widget.register, authNameCtrl.text, authPswCtrl.text);
                },
                child: const Text("退出登录")),
          ]),
        ));
  }
}