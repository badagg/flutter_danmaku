import 'package:c8u_desktop/danmu/models/danmu.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import './DanmuItem.dart';
import './controller.dart';

GlobalKey<_DanmuState> danmuKey = GlobalKey();

// 弹幕排序
List<DanmuItemData> _sortBySendTime(List data) {
  data.sort((a, b) => a.stime.compareTo(b.stime));
  return data;
}

class Danmu extends StatefulWidget {
  Danmu({Key key, this.data}) : super(key: key);

  final List<DanmuItemData> data;

  @override
  _DanmuState createState() => _DanmuState();
}

class _DanmuState extends State<Danmu> {
  DanmuController _danmuController =
      DanmuController(isPause: true, pauseTimeStamp: 0);
  List<DanmuItemData> _data;
  List<DanmuItemData> _preload;
  List<DanmuItem> _dmList = [];
  double _height;
  double _width;

  Map<String, dynamic> pipelines = Map();
  Map _getPipeLine(DanmuItemData danmu) {
    Map<String, dynamic> result = {'line': 0.0, 'duration': danmu.duration};

    int pipelineMaxCount = _height ~/ (danmu.size + 5);
    double duration = _getDanmuDuration(danmu);

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
          result['line'] = i;
          pipelines['$i'] = {'stime': newTime, 'danmu': danmu};
          break;
        }

        // 同一时间弹幕数量太多 会被过滤掉
        if (i == pipelineMaxCount - 1 && !canInsert) {
          result['line'] = -1;
        }
      } else {
        pipelines['$i'] = {'stime': 0, 'danmu': danmu};
        pipelines['0']['stime'] = newTime;
      }
    }

    result['duration'] = duration.toInt();
    return result;
  }

  double _getDanmuWidth(DanmuItemData danmu) {
    double dmWidth = danmu.text.length * danmu.size + 20;
    return dmWidth > _width ? _width : dmWidth;
  }

  double _getDanmuDuration(DanmuItemData danmu) {
    return (_width * 2) / ((_getDanmuWidth(danmu) + _width) / danmu.duration);
  }

  void _insert(DanmuItemData danmu) {
    Map pipe = _getPipeLine(danmu);
    double line = pipe['line'].toDouble();
    int duration = pipe['duration'];

    if (line == -1) {
      return;
    }

    _dmList.add(DanmuItem(
        key: UniqueKey(),
        controller: _danmuController,
        text: danmu.text,
        top: line * (danmu.size + 5),
        size: danmu.size,
        duration: duration,
        onComplete: (id) {
          _removeDanmuItemById(id);
        }));
    setState(() {});
  }

  bool pause() {
    _danmuController.isPause = !_danmuController.isPause;
    _danmuController.pauseTimeStamp =
        _danmuController.isPause ? DateTime.now().millisecondsSinceEpoch : 0;
    _danmuController.trigger();
    return _danmuController.isPause;
  }

  void _removeDanmuItemById(id) {
    _dmList.remove(id);
    setState(() {});
  }

  int lastInterval = 0;
  void _insertPreloadList() {
    List<DanmuItemData> preload = [];
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