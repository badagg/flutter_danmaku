import 'package:dio/dio.dart';
import 'http_config.dart';

class Http {
  static BaseOptions baseOptions = BaseOptions(baseUrl: BASE_URL, connectTimeout: TIMEOUT);
  static Dio dio = Dio(baseOptions);
  
  static Future request(String url, { String method = 'get', Map<String, dynamic> params, Options options }) async {

    Options _options = Options();
    if(options != null) _options = options;
    _options.method = method;
    
    try {
      return await dio.request(url, queryParameters: params, options: _options);
    } on DioError catch (err) {
      throw err;
    }
  }
}