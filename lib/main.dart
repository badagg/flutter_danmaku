import 'package:flutter/material.dart';
import 'danmu/Danmu.dart';
import 'dart:async';
import './danmu/DanmuData.dart';
import './danmu/models/danmu.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      showPerformanceOverlay: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page2'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<DanmuItemData> data = DanmuData.get();

  bool isPause = true;
  Timer timer;

  void start() {
    double fps = (1000 / 60);
    // 模拟播放timeline
    timer = Timer.periodic(Duration(milliseconds: fps.toInt()), (timer) {
      danmuKey.currentState.start();
    });
  }

  void pause() {
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar( title: Text(widget.title),),
      body: Danmu(
        key: danmuKey,
        data: data,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(isPause ? Icons.play_arrow : Icons.pause),
        onPressed: () {
          setState(() {
            isPause = danmuKey.currentState.pause();
            isPause ? pause() : start();
          });
        },
      ),
    );
  }
}
