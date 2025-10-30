import 'package:cached_network_image/cached_network_image.dart';
import 'package:fcc_home/vm/media_server_vm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

import 'display_page.dart';

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
        // ChangeNotifierProvider<DirInfos>(
        //   create: (ctx) => widget.vm.dirs,
        // ),
        // ChangeNotifierProvider<FileInfos>(create: (ctv) => widget.vm.listInfo),
        ChangeNotifierProvider<MediaInfos>(create: (ctx) => widget.vm.infos)
      ],
      child: PhotoWall(widget.vm.fetchUserDataInDir, widget.vm.fetchUserDirs,
          widget.vm.fetchPicsData, widget.vm.getDisplayVm),
    );
  }
}

class FolderStack {
  List<int> folder = [];

  void push(dir) {
    if (folder.isEmpty || dir != folder.last) {
      folder.add(dir);
    }
  }

  int pop() {
    try {
      var top = folder.last;
      folder.removeLast();
      return top;
    } catch (exp) {
      return -1;
    }
  }
}

class PhotoWall extends StatefulWidget {
  PhotoWall(
      this.getDirAndFiles, this.getDirs, this.getNextPage, this.getDisplayVm);

  bool isRoot = true;

  var upperDir = FolderStack();

  int currentDir = -1;

  int index = 0;

  int total = 0;

  Function getDirAndFiles;

  Function getDirs;

  // Function refreshFiles;

  Function getNextPage;

  Function getDisplayVm;

  @override
  State<StatefulWidget> createState() {
    return WallState();
  }
}

class WallState extends State<PhotoWall> {
  late SimpleFontelicoProgressDialog _progressDialog;

  final ScrollController _scrollController = ScrollController();

  Future<void> getCurrentDirs(dir) async {
    _progressDialog.show(message: "正在初始化文件夹");

    bool succeed = await widget.getDirAndFiles(dir);
    print("call fetch Dir and Files");
    _progressDialog.hide();
    if (succeed) {
      widget.upperDir.push(widget.currentDir);

      // if (dir != null && dir != -1) {
      //   widget.upperDir = widget.currentDir;
      // } else {
      //   widget.upperDir = -1;
      // }
      widget.currentDir = dir;
      print("upper: ${widget.upperDir.folder} current: ${widget.currentDir}");
    }
  }

  Future<void> backToTop(dir) async {
    _progressDialog.show(message: "正在初始化文件夹");

    bool succeed = await widget.getDirAndFiles(dir);
    print("call fetch Dir and Files");
    _progressDialog.hide();
    if (succeed) {
      // if (dir != null && dir != -1) {
      //   widget.upperDir = widget.currentDir;
      // } else {
      //   widget.upperDir = -1;
      // }
      widget.currentDir = dir;
      print("upper: ${widget.upperDir.folder} current: ${widget.currentDir}");
    }
  }

  // Future<void> getDirsFunc() async {
  //   _progressDialog.show(message: "正在初始化文件夹");
  //   bool succeed = await widget.getDirs();
  //   print("call fetchUserDirs ended");
  //   _progressDialog.hide();
  //   if (succeed) {
  //     widget.isRoot = true;
  //     widget.currentDir = -1;
  //     setState(() {});
  //   }
  // }

  // Future<void> initFileListFunc(dir) async {
  //   _progressDialog.show(message: "正在获取文件列表");
  //   bool succeed = await widget.getNextPage(dir);
  //   _progressDialog.hide();
  //   if (succeed) {
  //     widget.isRoot = false;
  //     widget.currentDir = dir;
  //     setState(() {});
  //   }
  // }

  Future<void> getNextPage() async {
    print("get next page index:${widget.index},total:${widget.total}");
    if (widget.index < widget.total) {
      _progressDialog.show(message: "正在获取更多文件");
      widget.getNextPage(widget.currentDir);
      _progressDialog.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MediaInfos>(
      builder: buildMediaList,
    );

/*    if (widget.isRoot) {
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
                        initFileListFunc(dirList.dirs[index].id);
                  },
                );
              }));
    } else {
      return Consumer<FileInfos>(
        builder: buildList,
      );
    }*/
  }

  // gridview
  Widget buildMediaList(BuildContext context, MediaInfos mediaList,
      Widget? child) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    widget.index = mediaList.list.length;
    widget.total = mediaList.getTotal();
    print("build list :itemcount:${widget.index} total:${widget.total}");
    return WillPopScope(
        child: GridView.builder(
          padding: const EdgeInsets.all(4),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, //每行显示列数2
              crossAxisSpacing: 4.0, //列间距
              mainAxisSpacing: 4.0, //行间距
              childAspectRatio: 1 //item的宽高比
          ),
          itemCount: mediaList.list.length,
          itemBuilder: (BuildContext context, int index) {
            // if(index+1 == fileList.dataList.length){
            //   widget.getNextPage(widget.currentDir);
            // }
            if (mediaList.list[index].isDir) {
              return Card(
                elevation: 4, //阴影
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2)), //圆角
                child: ListTile(
                  title: Container(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(mediaList.list[index].folder!.name,
                        style: TextStyle(color: colorScheme.onSurface)),
                  ),
                  onTap: () {
                    // initFileListFunc(mediaList.list[index].folder!.id);
                    getCurrentDirs(mediaList.list[index].folder!.id);
                  },
                ),
              );
            } else {
              String imgUrl;
              if (mediaList.list[index].file!.thumb.isEmpty) {
                imgUrl = mediaList.list[index].file!.url;
              } else {
                imgUrl = mediaList.list[index].file!.thumb;
              }

              return Container(
                  padding: const EdgeInsets.only(top: 4),
                  child: GestureDetector(
                    child: CachedNetworkImage(
                        imageUrl: imgUrl,
                        height: 400,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.medium,
                        placeholder: (context, url) => Container(
                              color: Colors.grey[300],
                              height: 400,
                            ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error)),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  DisplayPage.mode(
                                      url: mediaList.fileInfos.dataList
                                          .map((e) => e.url)
                                          .toList(),
                                      index: index - mediaList.getDirLength(),
                                      mode: ImgType.NETWORK,
                                      virtualVM: widget.getDisplayVm(
                                          mediaList.fileInfos.dataList))))
                          .then((value) {
                        setState(() {});
                      });

                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => DisplayPage(
                      //               url: mediaList.fileInfos.dataList
                      //                   .map((e) => e.url)
                      //                   .toList(),
                      // index:
                      //                   index - mediaList.dirInfos.dirs.length,
                      //             )));
                    },
                  ));
            }
          },
          controller: _scrollController,
        ),
        onWillPop: () async {
          //返回刷新
          //需要被优化
          backToTop(widget.upperDir.pop());
          // getDirsFunc();

          return false;
        });
  }

  //ListView
/*  Widget buildMediaList(
      BuildContext context, MediaInfos mediaList, Widget? child) {
    widget.index = mediaList.list.length;
    widget.total = mediaList.getTotal();
    print("build list :itemcount:${widget.index} total:${widget.total}");
    return WillPopScope(
        child: ListView.builder(
          padding: const EdgeInsets.all(4),
          itemCount: mediaList.list.length,
          itemBuilder: (BuildContext context, int index) {
            // if(index+1 == fileList.dataList.length){
            //   widget.getNextPage(widget.currentDir);
            // }
            if (mediaList.list[index].isDir) {
              return ListTile(
                title: Container(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(mediaList.list[index].folder!.name),
                ),
                onTap: () {
                  // initFileListFunc(mediaList.list[index].folder!.id);
                  getCurrentDirs(mediaList.list[index].folder!.id);
                },
              );
            } else {
              String imgUrl;
              if (mediaList.list[index].file!.thumb.isEmpty) {
                imgUrl = mediaList.list[index].file!.url;
              } else {
                imgUrl = mediaList.list[index].file!.thumb;
              }

              return Container(
                  padding: const EdgeInsets.only(top: 4),
                  child: GestureDetector(
                    child: CachedNetworkImage(
                        imageUrl: imgUrl,
                        height: 400,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.medium,
                        placeholder: (context, url) => Container(
                              color: Colors.grey[300],
                              height: 400,
                            ),
                        errorWidget: (context, url, error) => 
                            const Icon(Icons.error)),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                                  builder: (context) => DisplayPage.mode(
                                      url: mediaList.fileInfos.dataList
                                          .map((e) => e.url)
                                          .toList(),
                                      index: index - mediaList.getDirLength(),
                                      mode: ImgType.NETWORK,
                                      virtualVM: widget.getDisplayVm(
                                          mediaList.fileInfos.dataList))))
                          .then((value) {
                        setState(() {});
                      });

                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => DisplayPage(
                      //               url: mediaList.fileInfos.dataList
                      //                   .map((e) => e.url)
                      //                   .toList(),
                      // index:
                      //                   index - mediaList.dirInfos.dirs.length,
                      //             )));
                    },
                  ));
            }
          },
          controller: _scrollController,
        ),
        onWillPop: () async {
          //返回刷新
          //需要被优化
          backToTop(widget.upperDir.pop());
          // getDirsFunc();

          return false;
        });
  }*/

/*  Widget buildList(BuildContext context, FileInfos fileList, Widget? child) {
    widget.index = fileList.dataList.length;
    widget.total = fileList.total;
    print("build list :itemcount:${widget.index} total:${widget.total}");
    return WillPopScope(
        child: ListView.builder(
          padding: const EdgeInsets.all(4),
          itemCount: fileList.dataList.length,
          itemBuilder: (BuildContext context, int index) {
            // if(index+1 == fileList.dataList.length){
            //   widget.getNextPage(widget.currentDir);
            // }
            return Container(
                padding: const EdgeInsets.only(top: 4),
                child: GestureDetector(
                  child: Image.network(fileList.dataList[index].url,
                      height: 300,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.low),
                  onTap: () {
*/ /*                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DisplayPage(
                                test_url: fileList.dataList[index].url)));*/ /*
                  },
                ));
          },
          controller: _scrollController,
        ),
        onWillPop: () async {
          getDirsFunc();

          return false;
        });
  }*/

  @override
  void initState() {
    _progressDialog = SimpleFontelicoProgressDialog(
        context: context, barrierDimisable: false);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      getCurrentDirs(widget.currentDir);
      // getDirsFunc();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        print("get to the bottom");
        getNextPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
  }
}