import 'package:fcc_home/server_page_widget.dart';
import 'package:flutter/material.dart';

import 'mine_page_widget.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  void _incrementCounter() {
    setState(() {});
  }

  int _selectedIndex = 0;

  static const List<Widget> _pageWidget = <Widget>[
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
        child: _pageWidget.elementAt(_selectedIndex),
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
