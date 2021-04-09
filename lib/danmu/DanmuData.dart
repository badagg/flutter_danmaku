import '../public/utils.dart';
import '../assets/xml.dart';
import 'models/danmu.dart';


class DanmuData {
  static List<DanmuItemData> get() {
    final Map<String, dynamic> dm = xml2json(xml);
  
    final list = dm['i']['d'];
    List<DanmuItemData> dmList = [];

    for(var item in list) {
      var p = item['@p'].toString().split(',');
      Map<String, dynamic> map = {
        'stime': p[0],
        'mode': p[1],
        'size': p[2],
        'color': p[3],
        'date': p[4],
        'styleClass': p[5],
        'uid': p[6],
        'dmid': p[7],
        'text': item['\$']
      };
      dmList.add(DanmuItemData.fromMap(map));
    }
    
    return dmList;
  }
}