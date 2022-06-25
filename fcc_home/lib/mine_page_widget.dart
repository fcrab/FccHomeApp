import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MinePageWidget extends StatefulWidget {
  const MinePageWidget({Key? key}) : super(key: key);

  @override
  State createState() {
    return MinePageState();
  }
}

class MinePageState extends State<MinePageWidget> {
  Future<XFile?> getImgs() async {
    XFile? images = await ImagePicker().pickImage(source: ImageSource.gallery);
    return images;
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () {
          getImgs();
        },
        child: Text('test'));
  }
}
