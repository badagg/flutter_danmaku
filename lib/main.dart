import 'package:flutter/material.dart';
import 'danmu/Danmu.dart';
import 'dart:async';

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
  bool isPause = true;
  Timer timer;

  void start() {
    timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      danmuKey.currentState.insert();
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
