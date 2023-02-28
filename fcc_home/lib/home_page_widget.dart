import 'dart:convert';

import 'package:fcc_home/server_page_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'mine_page_widget.dart';

class HomePageWidget extends StatefulWidget {
  HomePageWidget({Key? key, required this.title, required this.platform})
      : super(key: key);
  final TargetPlatform platform;
  final String title;

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState(platform);
}

class _HomePageWidgetState extends State<HomePageWidget>
    with WidgetsBindingObserver {
  _HomePageWidgetState(this.defaultTargetPlatform) : super();
  static const platform = MethodChannel("com.crabfibber.fcc_home/event");
  final TargetPlatform defaultTargetPlatform;

  @override
  void initState() {
    print("demo page init state");
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (defaultTargetPlatform == TargetPlatform.android) {
        dynamic result = await platform.invokeMethod("requestPermission");
        print(result);
        if (result == true) {
          print("next step");
          dynamic pics = await platform.invokeListMethod("getAllPics");
          // print(pics);
          List<String> picsPath = [];
          for (String pic in pics) {
            Map<String, dynamic> picsMap = json.decode(pic);
            // print(picsMap['data']);
            picsPath.add(picsMap['data']);
          }
          (_pageWidget[0] as MinePageWidget).setList(picsPath);
        }
        // _initApp();
        // _listenToEvent();
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {}
    });
    WidgetsBinding.instance.addObserver(this);
  }

  void _incrementCounter() {
    setState(() {});
  }

  int _selectedIndex = 0;

  static final List<Widget> _pageWidget = <Widget>[
    MinePageWidget(),
    ServerPageWidget()
  ];

  void _onTapItem(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      drawer: const Drawer(
        child: Text("test"),
      ),
      body: Center(
        // child: _pageWidget.elementAt(_selectedIndex),
        child: IndexedStack(
          index: _selectedIndex,
          children: _pageWidget,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '我'),
          BottomNavigationBarItem(icon: Icon(Icons.cloud), label: '云')
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onTapItem,
      ),
    );
  }
}
