# flutter_danmaku
flutter版 弹幕实现

- xml格式解析
- 弹幕防撞(防重叠)
- 弹幕轨道个数根据容器高度自适应
- 弹幕方向可设置

# use

```dart
// widget
Danmu(key: danmuKey, data: data);

// api
danmuKey.currentState.start();
```

# preview
![avatar](https://raw.githubusercontent.com/badagg/flutter_danmaku/master/lib/assets/danmaku_preview.gif)
