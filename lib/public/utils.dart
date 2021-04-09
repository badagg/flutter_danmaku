import 'dart:convert';

import 'package:xml2json/xml2json.dart';

dynamic xml2json(String xml) {
  final transformer = Xml2Json();
  transformer.parse(xml);
  final result = transformer.toBadgerfish();
  return json.decode(result);
}