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
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        // width: ScreenUtil.instance.setWidth(400),
        // height: ScreenUtil.instance.setWidth(400),
        fit: BoxFit.contain,
        cache: true,
        // border: Border.all(color: Colors.red, width: 1.0),
        // shape: boxShape,
        // borderRadius: BorderRadius.all(Radius.circular(30.0)),
        mode: ExtendedImageMode.gesture,
        initGestureConfigHandler: (state) => GestureConfig(
            minScale: 0.9,
            animationMinScale: 0.7,
            maxScale: 3.0,
            animationMaxScale: 3.5,
            speed: 1.0,
            inertialSpeed: 100.0,
            initialScale: 1.0,
            inPageView: false),
        //cancelToken: cancellationToken,
      ),
    );
  }
}
