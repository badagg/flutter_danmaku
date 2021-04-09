class DanmuItemData {
  double stime;
  int mode;
  double size;
  int color;
  int date;
  int styleClass;
  String uid;
  String dmid;
  String text;
  int duration = 6000;

  DanmuItemData.fromMap(Map<String, dynamic> map) {
    this.stime = double.parse(map['stime']);
    this.mode = int.parse(map['mode']);
    this.size = double.parse(map['size']);
    this.color = int.parse(map['color']);
    this.date = int.parse(map['date']);
    this.styleClass = int.parse(map['styleClass']);
    this.uid = map['uid'];
    this.dmid = map['dmid'];
    this.text = map['text'];
  }
}