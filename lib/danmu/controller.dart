import 'package:flutter/material.dart';


class DanmuController extends ChangeNotifier {
  bool isPause;
  int pauseTimeStamp;

  DanmuController({this.isPause, this.pauseTimeStamp});

  trigger() {
    notifyListeners();
  }
}