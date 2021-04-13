import 'package:flutter/material.dart';
import 'danmaku/index.dart';
import 'dart:async';
import 'danmaku_data.dart';
import 'danmaku/models/danmaku.dart';

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
      home: DanmukuDemo(title: 'Flutter Demo Home Page2'),
    );
  }
}



class DanmukuDemo extends StatefulWidget {
  DanmukuDemo({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _DanmukuDemoState createState() => _DanmukuDemoState();
}

class _DanmukuDemoState extends State<DanmukuDemo> {
  final List<DanmakuItemModel> data = DanmuData.get();

  bool isPause = true;
  Timer timer;

  void start() {
    double fps = (1000 / 60);
    // 模拟播放timeline
    timer = Timer.periodic(Duration(milliseconds: fps.toInt()), (timer) {
      danmakuKey.currentState.start();
    });
  }

  void pause() {
    timer.cancel();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Danmaku(
        key: danmakuKey,
        data: data,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(isPause ? Icons.play_arrow : Icons.pause),
        onPressed: () {
          setState(() {
            isPause = danmakuKey.currentState.pause();
            isPause ? pause() : start();
          });
        },
      ),
    );
  }
}
