import 'package:fcc_home/entity/login_info.dart';
import 'package:fcc_home/vm/auth_vm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

/**
 * user auth
 */

typedef TestAction = void Function(String name, String password);

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

  void testAction(
      String name, String password, void Function(String state) callback) {
    try {
      // vm.sendTest(name, password);
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
      body: ChangeNotifierProvider<LoginInfo>(
        create: (context) => widget.vm.loginInfo,
        child: AuthPageBody(
            login: widget.loginAction, register: widget.registerAction),
      ),
    );
  }
}

class AuthPageBody extends StatefulWidget {
  AuthPageBody({Key? key, required this.login, required this.register})
      : super(key: key);
  var vm = AuthVM();
  Function login;

  Function register;

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
    _progressDialog.show(message: "请稍候");
    widget.login(
        authNameCtrl.text, authPswCtrl.text, () => {_progressDialog.hide()});

    //todo if get token then jump into homepage
    setState(() {});
  }

  Future<void> sendRegister() async {
    _progressDialog.show(message: "请稍候");
    widget.register(
        authNameCtrl.text, authPswCtrl.text, () => {_progressDialog.hide()});

    setState(() {});
  }

  void sendTest(LoginInfo info) {
    _progressDialog.show(message: "请稍候");
    widget.vm.sendTest(authNameCtrl.text, authPswCtrl.text);
    _progressDialog.hide();
    // widget.test( authPswCtrl.text,()=>{
    //   _progressDialog.hide()
    // });

    // setState(() {});
  }

  @override
  void initState() {
    _progressDialog = SimpleFontelicoProgressDialog(
        context: context, barrierDimisable: false);

    print("show me when you excute this function");
  }

  @override
  Widget build(BuildContext context) {
    // LoginInfo id = Provider.of<LoginInfo>(context,listen: false);

    return Consumer<LoginInfo>(builder: (_, info, child) {
      print("id: ${info.id} name:${info.name} password:${info.password}");

      return Center(
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
                  // sendLogin();
                  // info.testNoti();
                  sendTest(info);
                },
                child: const Text("登录")),
            TextButton(
                onPressed: () {
                  sendRegister();
                },
                child: const Text("注册")),
          ],
        ),
      );
    });
  }
}
