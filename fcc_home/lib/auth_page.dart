import 'package:fcc_home/entity/login_info.dart';
import 'package:fcc_home/vm/auth_vm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

/**
 * user auth
 */
class AuthPage extends StatefulWidget {
  var vm = AuthVM();

  AuthPage({Key? key}) : super(key: key);

  Future<void> loginAction(String name, String password,
      void Function(String state) callback) async {
    try {
      await vm.sendLogin(name, password);
    } catch (exp) {
      print(exp);
    } finally {
      callback("");
    }
  }

  Future<void> registerAction(String name, String password,
      void Function(String state) callback) async {
    try {
      await vm.sendLogin(name, password);
    } catch (exp) {
      print(exp);
    } finally {
      callback("");
    }
  }

  @override
  State createState() {
    return AuthPageState();
  }
}

class AuthPageState extends State<AuthPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("login")),
      body: Provider<LoginInfo>(
        create: (context) => widget.vm.loginInfo,
        child: AuthPageBody(login: widget.loginAction),
      ),
    );
  }
}

class AuthPageBody extends StatefulWidget {
  AuthPageBody({required this.login});

  Function login;

  @override
  State<StatefulWidget> createState() {
    return AuthPageBodyState();
  }
}

class AuthPageBodyState extends State<AuthPageBody> {
  late TextEditingController authNameCtrl;
  late TextEditingController authPswCtrl;

  late SimpleFontelicoProgressDialog _progressDialog;

  Future<void> sendLogin() async {
    // try {
    _progressDialog.show(message: "请稍候");
    widget.login(
        authNameCtrl.text, authPswCtrl.text, () => {_progressDialog.hide()});
    //vm.login(authNameCtrl.text, authPswCtrl.text){
    //  _progressDialog.hide();
    //}

    // } catch (exp) {
    //   print(exp);
    // } finally {
    //   _progressDialog.hide();
    // }

    setState(() {});
  }

  Future<void> sendRegister() async {
    _progressDialog.show(message: "请稍候");
    widget.login(
        authNameCtrl.text, authPswCtrl.text, () => {_progressDialog.hide()});
    // try {
    //
    //
    //   // var info = LoginInfo.info(name:authNameCtrl.text,password: authPswCtrl.text);
    //   var tokenMap = await client.register(authNameCtrl.text, authPswCtrl.text);
    //   if (tokenMap != null) {
    //     Map<String, dynamic> jsonObj = json.decode(tokenMap);
    //     HomeGlobal.saveAccessToken(jsonObj['access']);
    //     // HomeGlobal.saveRefreshToken(jsonObj['refresh']);
    //   }
    // } catch (exp) {
    //   print(exp);
    // } finally {
    //   _progressDialog.hide();
    // }
    //todo if get token then jump into homepage
    setState(() {});
  }

  @override
  void initState() {
    _progressDialog = SimpleFontelicoProgressDialog(
        context: context, barrierDimisable: false);
  }

  @override
  Widget build(BuildContext context) {
    // String loginInfo = Provider.of

    return Scaffold(
      appBar: AppBar(title: const Text("login")),
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
            TextButton(
                onPressed: () {
                  sendRegister();
                },
                child: const Text("注册")),
          ],
        ),
      ),
    );
  }
}
