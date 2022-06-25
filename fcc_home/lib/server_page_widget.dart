import 'package:flutter/material.dart';

/// 按日期排序，直接显示所有照片
class ServerPageWidget extends StatefulWidget {
  const ServerPageWidget({Key? key}) : super(key: key);

  @override
  State createState() {
    return ServerPageState();
  }
}

class ServerPageState extends State<ServerPageWidget> {
  List<String> entries = [
    'https://img1.mydrivers.com/img/20210329/209025c28e7c443bb6e070c39b6574b9.png',
    'https://www.zhifure.com/upload/images/2018/9/15212126838.jpg',
    'https://www.inbar.int/wp-content/uploads/2020/12/3.jpg'
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: const EdgeInsets.all(4),
        itemCount: entries.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            child: Center(child: Image.network(entries[index])),
          );
        });
  }
}
