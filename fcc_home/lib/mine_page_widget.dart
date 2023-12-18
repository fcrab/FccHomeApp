import 'dart:convert';
import 'dart:io';

import 'package:fcc_home/vm/mine_page_vm.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'display_page.dart';
import 'home_global.dart';

class MinePageWidget extends StatefulWidget {
  MinePageWidget({Key? key}) : super(key: key);

  var vm = MinePageVM();

  @override
  State createState() {
    return MinePageState();
  }
}

class MinePageState extends State<MinePageWidget> with WidgetsBindingObserver {
  MinePageState() : super();

  // List<String> entries = [];

  @override
  void initState() {
    print("demo page init state");
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (defaultTargetPlatform == TargetPlatform.android) {
        widget.vm.refreshDatas();

        setState(() {});

/*
        dynamic result =
            await HomeGlobal.platform.invokeMethod("requestPermission");
        print(result);
        if (result == true) {
          print("next step");
          dynamic pics =
              await HomeGlobal.platform.invokeListMethod("getAllPics");
          // print(pics);
          List<String> picsPath = [];
          for (String pic in pics) {
            Map<String, dynamic> picsMap = json.decode(pic);
            // print(picsMap['data']);
            picsPath.add(picsMap['data']);
          }
          setState(() {
            entries = picsPath;
          });

          // (_pageWidget[0] as MinePageWidget).setList(picsPath);
        }
*/
        // _initApp();
        // _listenToEvent();
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {}
    });
    WidgetsBinding.instance.addObserver(this);
  }

  // void updatePics(List<String> pathList) {
  //   print("update state${pathList.length}");
  //   // entries.clear();
  //   // entries.addAll(pathList);
  //   entries = pathList;
  //   print("update entries${entries.length}");
  //   setState(() {
  //     print("update state${entries.length}");
  //   });
  // }

  Future<XFile?> getImgs() async {
    XFile? images = await ImagePicker().pickImage(source: ImageSource.gallery);
    return images;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      children: List.generate(widget.vm.entries.length, (index) {
        return Container(
            // child: Center(child: Image.network(entries[index])),
            padding: const EdgeInsets.all(4),
            child: GestureDetector(
              child: Image(
                image: FileImage(File(widget.vm.entries[index]), scale: 0.1),
                height: 150,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.low,
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DisplayPage.mode(
                              url: widget.vm.entries,
                              index: index,
                              mode: ImgType.LOCAL,
                            ))).then((value) {
                  setState(() {});
                });
              },
            )

          // child: Image.file(File(entries[index]),
          //     fit: BoxFit.cover,
          //     height: 150,
          //     filterQuality: FilterQuality.low)

        );
      }),
    );

    return GridView.builder(
        padding: const EdgeInsets.all(4),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            childAspectRatio: 4 / 3,
            crossAxisSpacing: 4,
            mainAxisSpacing: 2),
        itemCount: entries.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            // child: Center(child: Image.network(entries[index])),
              padding: const EdgeInsets.only(top: 4),
              // child: Center(
              child: Image.file(File(entries[index]),
                  fit: BoxFit.cover,
                  height: 150,
                  filterQuality: FilterQuality.low)
            // ),
          );
        });
  }
}
