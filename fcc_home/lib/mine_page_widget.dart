import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MinePageWidget extends StatefulWidget {
  MinePageWidget({Key? key}) : super(key: key);

  final List<String> pics = [];

  void setList(List<String> picList) {
    pics.clear();
    pics.addAll(picList);
    // pics = picList;
    print("update page list");
    state.updatePics(pics);
  }

  MinePageState state = MinePageState([]);

  @override
  State createState() {
    print("init page state");
    return state = MinePageState(pics);
  }
}

class MinePageState extends State<MinePageWidget> {
  MinePageState(this.entries) : super();

  List<String> entries = [];

  void updatePics(List<String> pathList) {
    print("update state" + pathList.length.toString());
    // entries.clear();
    // entries.addAll(pathList);
    entries = pathList;
    print("update entries" + entries.length.toString());
    setState(() {
      print("update state" + entries.length.toString());
    });
  }

  Future<XFile?> getImgs() async {
    XFile? images = await ImagePicker().pickImage(source: ImageSource.gallery);
    return images;
  }

  // @override
  // Widget build(BuildContext context) {
  //   return ListView.builder(
  //       padding: const EdgeInsets.all(4),
  //       itemCount: entries.length,
  //       itemBuilder: (BuildContext context, int index) {
  //         return Container(
  //             // child: Center(child: Image.network(entries[index])),
  //             padding: const EdgeInsets.only(top: 4),
  //             // child: Center(
  //             child: Image.file(File(entries[index]),
  //                 fit: BoxFit.cover,
  //                 height: 150,
  //                 filterQuality: FilterQuality.low)
  //             // ),
  //             );
  //       });
  // }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      children: List.generate(entries.length, (index) {
        return Container(
            // child: Center(child: Image.network(entries[index])),
            padding: const EdgeInsets.all(4),
            child: Image(
              image: FileImage(File(entries[index]), scale: 0.1),
              height: 150,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.low,
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
