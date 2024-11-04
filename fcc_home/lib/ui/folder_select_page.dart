import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../vm/folder_select_page_vm.dart';

class FolderSelectPage extends StatefulWidget {
  var vm = FolderSelectPageVM();

  FolderSelectPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return FolderSelectState();
  }
}

class FolderSelectState extends State<FolderSelectPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    print("folder page init");
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (defaultTargetPlatform == TargetPlatform.android) {
        await widget.vm.initData();
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {}
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("切换目录"),
      ),
      body: ChangeNotifierProvider(
          create: (ctx) => widget.vm.entries,
          child: Consumer<OneFolders>(
            builder: (BuildContext context, OneFolders value, Widget? child) {
              return GridView.count(
                crossAxisCount: 2,
                //列边距
                crossAxisSpacing: 4,
                //行边距
                mainAxisSpacing: 4,
                //宽高比
                childAspectRatio: 3,
                children: List.generate(value.localList.length, (index) {
                  return Container(
                      // padding: const EdgeInsets.all(4),
                      alignment: const Alignment(0, 0),
                      color: Colors.blueGrey,
                      child: GestureDetector(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(value.localList[index].name),
                            Text(value.localList[index].count.toString())
                          ],
                        ),
                        onTap: () {
                          //todo 返回到上一页并且刷新
                          String tapName = value.localList[index].name;
                          print("on Tap return $tapName");
                          Navigator.pop(context, value.localList[index].id);
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => DisplayPage.mode(
                          //             url: widget.vm.entries,
                          //             index: index,
                          //             mode: ImgType.LOCAL,
                          //             virtualVM: widget.vm.detailVm!))).then((value) {
                          //   setState(() {});
                          // });
                        },
                      )

                      // child: Image.file(File(entries[index]),
                      //     fit: BoxFit.cover,
                      //     height: 150,
                      //     filterQuality: FilterQuality.low)

                      );
                }),
              );
            },
          )),
    );
  }
}
