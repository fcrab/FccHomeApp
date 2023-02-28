import 'package:fcc_home/vm/media_server_vm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

/// 按日期排序，直接显示所有照片
class ServerPageWidget extends StatefulWidget {
  ServerPageWidget({Key? key}) : super(key: key);

  MediaServerVM vm = MediaServerVM();

  @override
  State createState() {
    return ServerPageState();
  }
}

class ServerPageState extends State<ServerPageWidget>
    with WidgetsBindingObserver {
  late SimpleFontelicoProgressDialog _progressDialog;

/*
  var client = NetClient();

  Future<void> getDirs() async {
    try {
      var dirList = await client.getServerDirList(HomeGlobal.token);
      print(dirList);
    } catch (exp) {
      print(exp);
    }
  }

  Future<void> getPics() async {
    try {
      print('begin get file from server');
      _progressDialog.show(message: "请稍后");

      var fileList = await client.getServerPicsList(HomeGlobal.token, 0, page);

      if (fileList != null) {
        List<dynamic> jsonObj = json.decode(fileList);
        for (Map<String, dynamic> obj in jsonObj) {
          if (!obj['filepath'].toString().endsWith(".mov")) {
            entries.add(obj['filepath']);
          }
        }
        // HomeGlobal.saveAccessToken(jsonObj['access']);
        // HomeGlobal.saveRefreshToken(jsonObj['refresh']);
      }
    } catch (exp) {
      print(exp);
    } finally {
      _progressDialog.hide();
    }
    //todo if get token then jump into homepage
    setState(() {});
  }

  int size = 0;

  int page = 0;

  int total = 0;

  List<String> entries = [
    // 'https://img1.mydrivers.com/img/20210329/209025c28e7c443bb6e070c39b6574b9.png',
    // 'https://www.zhifure.com/upload/images/2018/9/15212126838.jpg',
    // 'https://www.inbar.int/wp-content/uploads/2020/12/3.jpg'
  ];
*/

  @override
  void initState() {
    print("server page init");
    _progressDialog = SimpleFontelicoProgressDialog(
        context: context, barrierDimisable: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // getDirs();
      // getPics();
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DirInfos>(
          create: (ctx) => widget.vm.dirs,
        ),
        ChangeNotifierProvider<FileInfos>(create: (ctv) => widget.vm.listInfo)
      ],
      child: PhotoWall(widget.vm.fetchUserDirs, widget.vm.fetchPicsData),
    );
  }
}

class PhotoWall extends StatefulWidget {
  PhotoWall(this.getDirs, this.getNextPage);

  bool isRoot = true;

  int currentDir = -1;

  Function getDirs;

  // Function refreshFiles;

  Function getNextPage;

  @override
  State<StatefulWidget> createState() {
    return WallState();
  }
}

class WallState extends State<PhotoWall> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    if (widget.isRoot) {
      return Consumer<DirInfos>(
          builder: (ctx, dirList, child) => ListView.builder(
              padding: const EdgeInsets.all(4),
              itemCount: dirList.dirs.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Container(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(dirList.dirs[index].name),
                  ),
                  onTap: () {
                    widget.isRoot = false;
                    widget.currentDir = dirList.dirs[index].id;
                    widget.getNextPage(widget.currentDir);
                    setState(() {});
                  },
                );
              }));
    } else {
      return Consumer<FileInfos>(
          builder: (ctx, fileList, child) => WillPopScope(
              child: ListView.builder(
                padding: const EdgeInsets.all(4),
                itemCount: fileList.dataList.length,
                itemBuilder: (BuildContext context, int index) {
                  // if(index+1 == fileList.dataList.length){
                  //   widget.getNextPage(widget.currentDir);
                  // }
                  return Container(
                    padding: const EdgeInsets.only(top: 4),
                    child: Image.network(fileList.dataList[index].url,
                        height: 300,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.low),
                  );
                },
                controller: _scrollController,
              ),
              onWillPop: () async {
                widget.isRoot = true;
                widget.currentDir = -1;
                widget.getDirs();
                setState(() {});
                return false;
              }));
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      widget.getDirs();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        print("get to the bottom");
        widget.getNextPage(widget.currentDir);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
  }
}
