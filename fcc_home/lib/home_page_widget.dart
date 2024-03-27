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

  FloatingActionButton? syncBtn;

  void _incrementCounter() {
    setState(() {});
  }

  int _selectedIndex = 0;

  @override
  void initState() {
    syncBtn = genSyncBtn();
  }

  FloatingActionButton genSyncBtn() {
    return FloatingActionButton(
      onPressed: () {
        //upload file test
        // (_pageWidget[0] as MinePageWidget).vm.checkFilesByIsolate();

        //check file sync state
        // (_pageWidget[0] as MinePageWidget).vm.refreshAndCheckFiles();

        //upload files
        (_pageWidget[0] as MinePageWidget).vm.syncFiles();
        print("first run here");
        // _incrementCounter();
      },
      tooltip: 'syncfiles',
      child: const Icon(Icons.sync),
    );
  }

  static final List<Widget> _pageWidget = <Widget>[
    MinePageWidget(),
    ServerPageWidget()
  ];

  void _onTapItem(int index) {
    setState(() {
      _selectedIndex = index;
      //todo 可以在这里控制切换
      if (_selectedIndex == 0) {
        syncBtn = genSyncBtn();
      } else {
        syncBtn = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        // actions: [
        // CustomAction(
        //   TextButton(
        //     onPressed: (){},
        //     child: const Column(
        //       children: [
        //         Icon(Icons.sync,color: Colors.black54,),
        //         Text("同步",
        //         style: TextStyle(color:Colors.black54,fontSize: 10),)
        //       ],
        //     ),
        //   ),true
        // ),
        // ],
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
      floatingActionButton: syncBtn,
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
