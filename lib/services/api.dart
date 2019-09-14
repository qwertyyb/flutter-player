import 'package:dio/dio.dart';
class Service {
  static Dio dio = new Dio(BaseOptions(
    baseUrl: "http://localhost:3000"
  ));

  static Future getList(page, size) async {
    return dio.get('/song/list');
  }
}