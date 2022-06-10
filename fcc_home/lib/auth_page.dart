import 'package:fcc_home/net_client.dart';
import 'package:flutter/material.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

/**
 * user auth
 */
class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State createState() {
    return AuthPageState();
  }
}

class AuthPageState extends State<AuthPage> {
  late TextEditingController authNameCtrl;
  late TextEditingController authPswCtrl;

  late SimpleFontelicoProgressDialog _progressDialog;

  var client = new NetClient();

  Future<void> sendLogin() async {
    try {
      _progressDialog.show(message: "请稍后");
      client.postLogin(authNameCtrl.text, authPswCtrl.text);
    } catch (exp) {
      print(exp);
    } finally {
      _progressDialog.hide();
    }
  }

  @override
  void initState() {
    _progressDialog = SimpleFontelicoProgressDialog(
        context: context, barrierDimisable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("login")),
      body: Center(
        child: Column(
          children: [
            const Text('账号'),
            TextField(
              controller: authNameCtrl = TextEditingController(text: ""),
              maxLines: 1,
            ),
            const Text('密码'),
            TextField(
              controller: authPswCtrl = TextEditingController(text: ""),
              maxLines: 1,
            ),
            TextButton(
                onPressed: () {
                  sendLogin();
                },
                child: const Text("登录")),
          ],
        ),
      ),
    );
  }
}
