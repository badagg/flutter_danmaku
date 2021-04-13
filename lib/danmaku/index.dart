import 'package:flutter/material.dart';
import 'dart:math';
import 'bullet.dart';
import 'controller.dart';
import 'models/danmaku.dart';

GlobalKey<_DanmakuState> danmakuKey = GlobalKey();

// 弹幕排序
List<DanmakuItemModel> _sortBySendTime(List data) {
  data.sort((a, b) => a.stime.compareTo(b.stime));
  return data;
}

class Danmaku extends StatefulWidget {
  Danmaku({Key key, this.data}) : super(key: key);

  final List<DanmakuItemModel> data;

  @override
  _DanmakuState createState() => _DanmakuState();
}

class _DanmakuState extends State<Danmaku> {
  DanmakuController _danmakuController =
      DanmakuController(isPause: true, pauseTimeStamp: 0);
  List<DanmakuItemModel> _data;
  List<DanmakuItemModel> _preload;
  List<Bullet> _dmList = [];
  double _height;
  double _width;

  Map<String, dynamic> pipelines = Map();
  int _getPipeLine(DanmakuItemModel danmu) {
    int line = 0;
    int pipelineMaxCount = _height ~/ danmu.size;
    int newTime = DateTime.now().millisecondsSinceEpoch;

    for (var i = 0; i < pipelineMaxCount; i++) {
      if (pipelines['$i'] != null) {
        var old = pipelines['$i'];
        var oldW = _getDanmuWidth(old['danmu']);
        var oldV = _width * 2 / _getDanmuDuration(old['danmu']);
        var newV = _width * 2 / _getDanmuDuration(danmu);
        var newT = max((_width + oldW) / oldV - _width / newV, oldW / oldV);

        bool canInsert = newTime - old['stime'] > newT;
        if (old['stime'] == 0 || canInsert) {
          line = i;
          pipelines['$i'] = {'stime': newTime, 'danmu': danmu};
          break;
        }

        // 同一时间弹幕数量太多 会被过滤掉
        if (i == pipelineMaxCount - 1 && !canInsert) {
          line = -1;
        }
      } else {
        pipelines['$i'] = {'stime': 0, 'danmu': danmu};
        pipelines['0']['stime'] = newTime;
      }
    }

    return line;
  }

  double _getDanmuWidth(DanmakuItemModel danmu) {
    double dmWidth = danmu.text.length * danmu.size;
    return dmWidth > _width ? _width : dmWidth;
  }

  double _getDanmuDuration(DanmakuItemModel danmu) {
    return (_width * 2) / ((_getDanmuWidth(danmu) + _width) / danmu.duration);
  }

  void _insert(DanmakuItemModel danmu) {
    double line = _getPipeLine(danmu).toDouble();
    int duration = _getDanmuDuration(danmu).toInt();

    if (line == -1) {
      return;
    }

    _dmList.add(Bullet(
        key: UniqueKey(),
        controller: _danmakuController,
        text: danmu.text,
        top: line * danmu.size,
        size: danmu.size,
        duration: duration,
        onComplete: (id) {
          _removeDanmuItemById(id);
        }));
    setState(() {});
  }

  bool pause() {
    _danmakuController.isPause = !_danmakuController.isPause;
    _danmakuController.trigger();
    return _danmakuController.isPause;
  }

  void _removeDanmuItemById(id) {
    _dmList.remove(id);
    setState(() {});
  }

  int lastInterval = 0;
  void _insertPreloadList() {
    List<DanmakuItemModel> preload = [];
    for (var i = 0; i < _data.length; i++) {
      if (_data[i].stime >= lastInterval && _data[i].stime < lastInterval + 1) {
        preload.add(_data[i]);
      }
    }
    _preload = preload;

    lastInterval++;
  }

  int fps = 0;
  void start() {
    // 按照一秒的间隔 把数据装载到预发list
    if (fps % 60 == 0) {
      _insertPreloadList();
    }

    // 按照外部fps的刷新率 来从预发里面找到范围内的弹幕并渲染到舞台
    double _start = fps / 60;
    double _end = (fps + 1) / 60;
    for (var i = 0; i < _preload.length; i++) {
      if (_preload[i].stime >= _start && _preload[i].stime < _end) {
        // print('${_preload[i].stime}, ${_preload[i].text}');
        _insert(_preload[i]);
      }
    }

    fps++;
  }

  @override
  void initState() {
    super.initState();
    _data = _sortBySendTime(widget.data);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // print(constraints.biggest);
      _height = constraints.biggest.height;
      _width = constraints.biggest.width;
      // print(_height);

      return Stack(
        alignment: Alignment.topRight,
        children: []..addAll(_dmList),
      );
    });
  }
}