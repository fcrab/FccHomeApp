import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:fcc_home/vm/detail_virtual_vm.dart';
import 'package:fcc_home/vm/display_page_vm.dart';
import 'package:flutter/material.dart';

enum ImgType { LOCAL, NETWORK }

class DisplayPage extends StatefulWidget {
  // String test_url;
  // Function getFile;

  // Function loadNextPage;

  ImgType mode = ImgType.NETWORK;

  late DisplayVM vm;

  // List<String> url = [];

  int index = 0;

  DisplayPage({Key? key, required url, required this.index}) : super(key: key) {
    vm.urls = url;
    vm = DisplayVM();
  }

  DisplayPage.mode(
      {Key? key,
      required url,
      required this.index,
      required this.mode,
      required DetailVirtualVM virtualVM})
      : super(key: key) {
    vm = DisplayVM.vm(virtualVM);
    vm.urls = url;
  }

  @override
  State<StatefulWidget> createState() {
    return DisplayPageState();
  }
}

class DisplayPageState extends State<DisplayPage> {
  late PageController controller;
  var barTitle = "";
  var pageIndex = -1;

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  void initState() {
    super.initState();
    controller = PageController(initialPage: widget.index);
    barTitle = widget.vm.getName(widget.index);
    pageIndex = widget.index;
  }

  void setBarTitle(int index) {
    var titleName = widget.vm.getName(index);
    print("init: $index name: $titleName");
    setState(() {
      barTitle = titleName;
    });
  }

  @override
  Widget build(BuildContext context) {
    var children = <Widget>[];
    for (int count = 0; count < widget.vm.urls.length; count++) {
      children.add(PageImgWidget(
          type: widget.mode, url: widget.vm.urls[count]));
    }

    var barActions = [
      IconButton(
          onPressed: () {
            setState(() {
              widget.vm.deletePic(pageIndex);
            });
          },
          icon: const Icon(Icons.delete_outline))
    ];
    if (widget.mode == ImgType.NETWORK) {
      barActions = [];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(barTitle),
        actions: barActions,
      ),
      body: PageView(
        controller: controller,
        children: children,
        onPageChanged: (int index) {
          pageIndex = index;
          setBarTitle(index);
        },
      ),
      // body:
      //   GestureDetector(
      //     child: PageImgWidget(type: ImgType.LOCAL,url: widget.url[widget.index],),
      //   )
    );
  }
}

class PageImgWidget extends StatefulWidget {
  ImgType type;

  String url;

  PageImgWidget(
      {Key? key,
      required this.type,
    required this.url,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PageImgState();
  }
}

class PageImgState extends State<PageImgWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type == ImgType.NETWORK) {
      return ExtendedImage.network(
        widget.url,
        // width: MediaQuery.of(context).size.width,
        // height: MediaQuery.of(context).size.height,
        width: 600,
        height: 600,
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
            inPageView: true),
        //cancelToken: cancellationToken,
      );
    } else {
      return ExtendedImage.file(
        File(widget.url),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        // width: ScreenUtil.instance.setWidth(400),
        // height: ScreenUtil.instance.setWidth(400),
        fit: BoxFit.contain,
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
            inPageView: true),
        //cancelToken: cancellationToken,
      );

      // return ExtendedImage.file(
      //   file:File(widget.url),
      //   width: MediaQuery.of(context).size.width,
      //   height: MediaQuery.of(context).size.height,
      //   // width: ScreenUtil.instance.setWidth(400),
      //   // height: ScreenUtil.instance.setWidth(400),
      //   fit: BoxFit.contain,
      //   // border: Border.all(color: Colors.red, width: 1.0),
      //   // shape: boxShape,
      //   // borderRadius: BorderRadius.all(Radius.circular(30.0)),
      //   mode: ExtendedImageMode.gesture,
      //   initGestureConfigHandler: (state) => GestureConfig(
      //       minScale: 0.9,
      //       animationMinScale: 0.7,
      //       maxScale: 3.0,
      //       animationMaxScale: 3.5,
      //       speed: 1.0,
      //       inertialSpeed: 100.0,
      //       initialScale: 1.0,
      //       inPageView: true),
      //   //cancelToken: cancellationToken,
      // );
    }
  }
}