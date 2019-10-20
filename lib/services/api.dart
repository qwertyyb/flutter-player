import 'package:dio/dio.dart';
import 'package:oktoast/oktoast.dart';
class Service {
  // 工厂模式
  factory Service() =>_getInstance();
  static Service get instance => _getInstance();
  static Service _instance;
  Service._internal() {
    // 初始化
    dio.interceptors.add(InterceptorsWrapper(
      onError: (DioError err) async {
        print(err);
        showToast(err.message);
        return err;
      }
    ));
  }
  static Service _getInstance() {
    if (_instance == null) {
      _instance = new Service._internal();
    }
    return _instance;
  }

  Dio dio = new Dio(BaseOptions(
    baseUrl: "https://music-default-1253524658.ap-guangzhou.tencentserverless.com"
  ));

  Future getList(page, size) async {
    return await dio.get('/song/list');
  }
}