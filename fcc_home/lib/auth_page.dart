import 'package:fcc_home/entity/login_info.dart';
import 'package:fcc_home/vm/auth_vm.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

import 'home_page_widget.dart';

/**
 * user auth
 */

// typedef TestAction = void Function(String name, String password);

class AuthPage extends StatefulWidget {
  var vm = AuthVM();

  AuthPage({Key? key}) : super(key: key);

  Future<void> _loginAction(String name, String password) async {
    try {
      await vm.sendLogin(name, password);
    } catch (exp) {
      print(exp);
    } finally {}
  }

  Future<void> _registerAction(String name, String password,
      void Function(String state) callback) async {
    try {
      await vm.sendRegister(name, password);
    } catch (exp) {
      print(exp);
    } finally {
      callback("");
    }
  }

  void _testAction(String name, String password) {
    print("call test action from child");

    try {
      vm.sendTest(name, password);
    } catch (exp) {
      print(exp);
    } finally {
      // callback("");
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
            login: widget._loginAction,
            register: widget._registerAction,
            test: widget._testAction),
      ),
    );
  }
}

class AuthPageBody extends StatefulWidget {
  var vm = AuthVM();
  Function login;

  Function register;

  Function test;

  AuthPageBody(
      {Key? key,
      required this.login,
      required this.register,
      required this.test})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AuthPageBodyState();
  }
}

class AuthPageBodyState extends State<AuthPageBody> {
  late TextEditingController authNameCtrl;
  late TextEditingController authPswCtrl;

  late SimpleFontelicoProgressDialog _progressDialog;

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

      if (info.id != "") {
        print("id has been refresh");
        //需要在build后再执行
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          print("call after state build");
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => HomePageWidget(
                      title: 'Home Page', platform: defaultTargetPlatform)));
        });

        //another way
        SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
          //action in next frame
          // print("action in schedule");
        });

        //another new way
        Future.microtask(() => {});
      }

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
                  widget.login(authNameCtrl.text, authPswCtrl.text);
                  // widget.test(authNameCtrl.text,authPswCtrl.text);
                },
                child: const Text("登录")),
            TextButton(
                onPressed: () {
                  // sendRegister();
                  widget.register(authNameCtrl.text, authPswCtrl.text);
                },
                child: const Text("注册")),
          ],
        ),
      );
    });
  }
}
