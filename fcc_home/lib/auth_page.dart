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
            login: widget.vm.sendLogin,
            register: widget.vm.sendRegister,
            verifyLocal: widget.vm.verifyLocal),
      ),
    );
  }
}

class AuthPageBody extends StatefulWidget {
  var vm = AuthVM();
  Function login;

  Function register;

  Function verifyLocal;

  AuthPageBody(
      {Key? key,
      required this.login,
      required this.register,
      required this.verifyLocal})
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

    print("show me when you execute this function");
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      verifyLocal();
    });
  }

  Future<void> verifyLocal() async {
    _progressDialog.show(message: "正在校验信息,请稍候");
    await widget.verifyLocal();
    _progressDialog.hide();
  }

  Future<void> execute(Function func, name, psw) async {
    _progressDialog.show(message: "正在通信,请稍候");
    await func(name, psw);
    _progressDialog.hide();
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
                  // widget.login(authNameCtrl.text, authPswCtrl.text);
                  execute(widget.login, authNameCtrl.text, authPswCtrl.text);
                },
                child: const Text("登录")),
            TextButton(
                onPressed: () {
                  // widget.register(authNameCtrl.text, authPswCtrl.text);
                  execute(widget.register, authNameCtrl.text, authPswCtrl.text);
                },
                child: const Text("注册")),
          ],
        ),
      );
    });
  }
}
