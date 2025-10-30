import 'package:fcc_home/home_global.dart';
import 'package:fcc_home/ui/auth_page.dart';
import 'package:fcc_home/ui/server_page_widget.dart';
import 'package:fcc_home/util/wake_rock.dart';
import 'package:flutter/material.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

import '../util/AppColors.dart';
import 'folder_select_page.dart';
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

  late List<PopupMenuEntry<String>> _menuList;

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

    _pageWidget = <Widget>[
      MinePageWidget(homeAction: setTitle),
      ServerPageWidget()
    ];

    syncBtn = genSyncBtn();
    _menuList = genMenuItemList('default');
  }

  List<PopupMenuEntry<String>> genMenuItemList(String mode) {
    switch (mode) {
      case 'default':
        return {'切换文件夹', '全选', '删除'}.map((String choice) {
          return PopupMenuItem<String>(
            value: choice,
            child: Text(choice),
          );
        }).toList();
      case 'explorer':
        return {'全选', '浏览'}.map((String choice) {
          return PopupMenuItem<String>(
            value: choice,
            child: Text(choice),
          );
        }).toList();
      default:
        return [];
    }
  }

  FloatingActionButton genSyncBtn() {
    if ((_pageWidget[0] as MinePageWidget).vm.getDelMode()) {
      return FloatingActionButton(
          backgroundColor: AppColors.primaryColor,
          onPressed: () async {
            _progressDialog.show(message: '正在删除文件');
            await (_pageWidget[0] as MinePageWidget).vm.deleteData();
            _progressDialog.hide();
          },
          tooltip: 'delfiles',
          child: const Icon(
            Icons.delete,
            color: Colors.white,
          ));
    } else {
      return FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        onPressed: () async {
          print("click upload");
          await enableScreen();
          _progressDialog.show(message: "正在同步文件");

          //upload file test
          // (_pageWidget[0] as MinePageWidget).vm.checkFilesByIsolate();

          //check file sync state
          // (_pageWidget[0] as MinePageWidget).vm.refreshAndCheckFiles();

          //upload files
          await (_pageWidget[0] as MinePageWidget).vm.syncFiles().then((value) {
            print("truely upload successful");
            disableScreen();
            _progressDialog.hide();
          });
          print("after upload");
          // _incrementCounter();
        },
        tooltip: 'syncfiles',
        child: const Icon(
          Icons.sync,
          color: Colors.white,
        ),
      );
    }
  }

  void _onTapItem(int index) {
    setState(() {
      _selectedIndex = index;
      //todo 可以在这里控制切换
      if (_selectedIndex == 0) {
        syncBtn = genSyncBtn();
        _menuList = genMenuItemList('default');
      } else {
        syncBtn = null;
        _menuList = genMenuItemList('');
      }
    });
  }

  Future<void> _onMenuClick(String value) async {
    if (value == "切换文件夹") {
      String result = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => FolderSelectPage()));
      if (!context.mounted) return;

      print("select result is $result");
      (_pageWidget[0] as MinePageWidget).vm.initData(result);
    } else if (value == '删除') {
      // (_pageWidget[0] as MinePageWidget).vm.deleteData();
      (_pageWidget[0] as MinePageWidget).vm.setMode();
      setState(() {
        if (_selectedIndex == 0) {
          syncBtn = genSyncBtn();
          _menuList = genMenuItemList('explorer');
        } else {
          syncBtn = null;
        }
      });
    } else if (value == '浏览') {
      (_pageWidget[0] as MinePageWidget).vm.setMode();
      setState(() {
        if (_selectedIndex == 0) {
          syncBtn = genSyncBtn();
          _menuList = genMenuItemList('default');
        } else {
          syncBtn = null;
        }
      });
    } else if (value == '全选') {
      (_pageWidget[0] as MinePageWidget).vm.selectAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
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
              return _menuList;
              // return {'切换文件夹', '全选','删除'}.map((String choice) {
              //   return PopupMenuItem<String>(
              //     value: choice,
              //     child: Text(choice),
              //   );
              // }).toList();
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
              decoration: BoxDecoration(color: colorScheme.primary),
              child: Text(name, style: TextStyle(color: colorScheme.onPrimary)),
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
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.tertiary,
        onTap: _onTapItem,
      ),
    );
  }
}