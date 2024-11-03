import 'package:fcc_home/home_global.dart';
import 'package:fcc_home/ui/auth_page.dart';
import 'package:fcc_home/ui/server_page_widget.dart';
import 'package:flutter/material.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

import 'mine_page_widget.dart';

class HomePageWidget extends StatefulWidget {
  HomePageWidget({Key? key, required this.title, required this.platform})
      : super(key: key);
  final TargetPlatform platform;
  String title;

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState(platform);
}

class _HomePageWidgetState extends State<HomePageWidget>
    with WidgetsBindingObserver {
  late SimpleFontelicoProgressDialog _progressDialog;

  _HomePageWidgetState(this.defaultTargetPlatform) : super();
  final TargetPlatform defaultTargetPlatform;

  FloatingActionButton? syncBtn;

  void setTitle(String barTitle) {
    setState(() {
      widget.title = barTitle;
    });
  }

  int _selectedIndex = 0;

  static late List<Widget> _pageWidget;

  @override
  void initState() {
    _progressDialog = SimpleFontelicoProgressDialog(
        context: context, barrierDimisable: false);

    syncBtn = genSyncBtn();

    _pageWidget = <Widget>[
      MinePageWidget(homeAction: setTitle),
      ServerPageWidget()
    ];
  }

  FloatingActionButton genSyncBtn() {
    return FloatingActionButton(
      onPressed: () async {
        print("click upload");
        _progressDialog.show(message: "正在同步文件");

        //upload file test
        // (_pageWidget[0] as MinePageWidget).vm.checkFilesByIsolate();

        //check file sync state
        // (_pageWidget[0] as MinePageWidget).vm.refreshAndCheckFiles();

        //upload files
        await (_pageWidget[0] as MinePageWidget).vm.syncFiles().then((value) {
          print("truely upload successful");
          _progressDialog.hide();
        });
        print("after upload");
        // _incrementCounter();
      },
      tooltip: 'syncfiles',
      child: const Icon(Icons.sync),
    );
  }

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

  void _onMenuClick(String value) {}

  @override
  Widget build(BuildContext context) {
    String name =
        HomeGlobal.loginInfo != null ? HomeGlobal.loginInfo!.name : "";
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: _onMenuClick,
            itemBuilder: (BuildContext context) {
              return {'切换文件夹', '全选'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
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

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFFFF8F00)),
              child: Text(name),
            ),
            ListTile(
              title: const Text('个人中心'),
              onTap: () {
                Navigator.pushNamed(context, "personal_page");
              },
            ),
            ListTile(
              title: const Text('退出登录'),
              onTap: () {
                HomeGlobal.clean();
                // Navigator.pushNamed(context, "/");
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => AuthPage()),
                    (route) => false);
              },
            )
          ],
        ),
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
