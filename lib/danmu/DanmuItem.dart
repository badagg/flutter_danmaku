import 'package:flutter/material.dart';
import './controller.dart';

enum TransitionDirection {
  // 从左到右
  ltr,
  // 从右到左
  rtl,
}

class DanmuItem extends StatefulWidget {
  final int id;
  final double stime;
  final int mode;
  final double size;
  final int color;
  final int date;
  final int styleClass;
  final String uid;
  final String dmid;
  final String text;
  final int duration;
  final double top;

  final TransitionDirection direction;
  final ValueChanged onComplete;

  final DanmuController controller;

  DanmuItem(
      {Key key,
      this.id,
      this.stime,
      this.mode,
      this.size,
      this.color,
      this.date,
      this.styleClass,
      this.uid,
      this.dmid,
      this.text,
      this.duration = 6000,
      this.top = 0,
      this.direction = TransitionDirection.rtl,
      this.onComplete,
      this.controller})
      : super(key: key);

  @override
  _DanmuItemState createState() => _DanmuItemState();
}

class _DanmuItemState extends State<DanmuItem>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
        duration: Duration(milliseconds: widget.duration), vsync: this)
      ..addStatusListener(_animationStatusHandle);

    var begin = Offset(1.0, .0);
    var end = Offset(-1.0, .0);
    switch (widget.direction) {
      case TransitionDirection.ltr:
        begin = Offset(-1.0, .0);
        end = Offset(1.0, .0);
        break;
      case TransitionDirection.rtl:
      default:
        begin = Offset(1.0, .0);
        end = Offset(-1.0, .0);
        break;
    }

    _animation = Tween(begin: begin, end: end).animate(_animationController);

    if (!widget.controller.isPause) {
      _animationController.forward();
    }

    widget.controller?.addListener(_pause);
  }

  void _animationStatusHandle(status) {
    if (status == AnimationStatus.completed) {
      // print('${widget.text} -- End');
      widget.onComplete(widget);
    }
  }

  void _pause() {
    if (widget.controller.isPause) {
      _animationController.stop();
    } else {
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      top: widget.top,
      child: SlideTransition(
        position: _animation,
        child: Text(
          '${widget.text}',
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: widget.size),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.removeStatusListener(_animationStatusHandle);
    _animationController.dispose();
    _animation = null;
    widget.controller.removeListener(_pause);
    super.dispose();
  }
}
