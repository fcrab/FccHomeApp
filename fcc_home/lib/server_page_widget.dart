import 'dart:convert';

import 'package:fcc_home/home_global.dart';
import 'package:flutter/material.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

import 'net_client.dart';

/// 按日期排序，直接显示所有照片
class ServerPageWidget extends StatefulWidget {
  const ServerPageWidget({Key? key}) : super(key: key);

  @override
  State createState() {
    return ServerPageState();
  }
}

class ServerPageState extends State<ServerPageWidget>
    with WidgetsBindingObserver {
  late SimpleFontelicoProgressDialog _progressDialog;

  var client = NetClient();

  Future<void> getDirs() async {
    try {
      var dirList = await client.getServerDirList(HomeGlobal.token);
      print(dirList);
    } catch (exp) {
      print(exp);
    }
  }

  Future<void> getPics() async {
    try {
      print('begin get file from server');
      _progressDialog.show(message: "请稍后");

      var fileList = await client.getServerPicsList(HomeGlobal.token, 0, page);

      if (fileList != null) {
        List<dynamic> jsonObj = json.decode(fileList);
        for (Map<String, dynamic> obj in jsonObj) {
          if (!obj['filepath'].toString().endsWith(".mov")) {
            entries.add(obj['filepath']);
          }
        }
        // HomeGlobal.saveAccessToken(jsonObj['access']);
        // HomeGlobal.saveRefreshToken(jsonObj['refresh']);
      }
    } catch (exp) {
      print(exp);
    } finally {
      _progressDialog.hide();
    }
    //todo if get token then jump into homepage
    setState(() {});
  }

  int size = 0;

  int page = 0;

  int total = 0;

  List<String> entries = [
    // 'https://img1.mydrivers.com/img/20210329/209025c28e7c443bb6e070c39b6574b9.png',
    // 'https://www.zhifure.com/upload/images/2018/9/15212126838.jpg',
    // 'https://www.inbar.int/wp-content/uploads/2020/12/3.jpg'
  ];

  @override
  void initState() {
    print("server page init");
    _progressDialog = SimpleFontelicoProgressDialog(
        context: context, barrierDimisable: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getDirs();
      // getPics();
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: const EdgeInsets.all(4),
        itemCount: entries.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            padding: const EdgeInsets.only(top: 4),
            child: Image.network(entries[index],
                height: 300,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.low),
          );
        });
  }
}
