import 'package:c8u_desktop/danmu/models/danmu.dart';
import 'package:flutter/material.dart';
import 'DanmuData.dart';
import './DanmuItem.dart';
import './controller.dart';

GlobalKey<_DanmuState> danmuKey = GlobalKey();

class Danmu extends StatefulWidget {
  Danmu({Key key}) : super(key: key);

  @override
  _DanmuState createState() => _DanmuState();
}

class _DanmuState extends State<Danmu> {
  final List<DanmuItemData> dmData = DanmuData.get();

  final List<DanmuItem> dmList = [];

  double _height;
  double _width;
  int index = 0;

  DanmuController _danmuController =
      DanmuController(isPause: true, pauseTimeStamp: 0);

  Map<String, dynamic> pipelines = Map();
  Map _getPipeLine(dm) {
    Map<String, dynamic> result = {'line': 0.0, 'duration': dm.duration};

    int pipelineMaxCount = _height ~/ (dm.size + 5);
    double duration = _getDanmuDuration(dm);

    int newTime = DateTime.now().millisecondsSinceEpoch;

    for (var i = 0; i < pipelineMaxCount; i++) {
      if (pipelines['$i'] != null) {
        var old = pipelines['$i'];
        var oldW = _getDanmuWidth(old['danmu']);
        var oldV = _width * 2 / _getDanmuDuration(old['danmu']);
        var newV = _width * 2 / _getDanmuDuration(dm);
        var newT = _max((_width + oldW) / oldV - _width / newV, oldW / oldV);
        
        bool canInsert = newTime - old['stime'] > newT;
        if (old['stime'] == 0 || canInsert) {
          result['line'] = i;
          pipelines['$i'] = {'stime': newTime, 'danmu': dm};
          break;
        }

        // 同一时间弹幕数量太多 会被过滤掉
        if (i == pipelineMaxCount - 1 && !canInsert) {
          result['line'] = -1;
        }
      } else {
        pipelines['$i'] = {'stime': 0, 'danmu': dm};
        pipelines['0']['stime'] = newTime;
      }
    }

    result['duration'] = duration.toInt();
    return result;
  }

  double _getDanmuWidth(dm) {
    double dmWidth = dm.text.length * dm.size + 20;
    return dmWidth > _width ? _width : dmWidth;
  }

  double _getDanmuDuration(dm) {
    return (_width * 2) / ((_getDanmuWidth(dm) + _width) / dm.duration);
  }

  double _max(a, b) {
    return a >= b ? a : b;
  }

  void insert() {
    if (index > dmData.length - 1) index = 0;
    DanmuItemData data = dmData[index++];
    Map pipe = _getPipeLine(data);
    double line = pipe['line'].toDouble();
    int duration = pipe['duration'];

    if (line == -1) {
      return;
    }

    dmList.add(DanmuItem(
        key: UniqueKey(),
        controller: _danmuController,
        id: index,
        text: data.text,
        top: line * (data.size + 5),
        size: data.size,
        duration: duration,
        onComplete: (id) {
          removeDanmuItemById(id);
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

  void removeDanmuItemById(id) {
    dmList.remove(id);
    setState(() {});
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
        children: []..addAll(dmList),
      );
    });
  }
}
