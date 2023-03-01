import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class DisplayPage extends StatefulWidget {
  String test_url;

  DisplayPage({Key? key, required this.test_url}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return DisplayPageState();
  }
}

class DisplayPageState extends State<DisplayPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("display")),
      body: ExtendedImage.network(
        widget.test_url,
        // width: ScreenUtil.instance.setWidth(400),
        // height: ScreenUtil.instance.setWidth(400),
        fit: BoxFit.fill,
        cache: true,
        // border: Border.all(color: Colors.red, width: 1.0),
        // shape: boxShape,
        borderRadius: BorderRadius.all(Radius.circular(30.0)),
        //cancelToken: cancellationToken,
      ),
    );
  }
}
