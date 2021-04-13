import 'package:flutter/material.dart';


class DanmakuController extends ChangeNotifier {
  bool isPause;
  int pauseTimeStamp;

  DanmakuController({this.isPause, this.pauseTimeStamp});

  trigger() {
    notifyListeners();
  }
}