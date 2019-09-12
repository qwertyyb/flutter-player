import 'package:dio/dio.dart';

class GithubClient {
  String _token;
  Dio _http = new Dio();
  _Gist gist;
  GithubClient({String token}) {
    _token = token;
    BaseOptions options = new BaseOptions(
      baseUrl: 'https://api.github.com',
      headers: {
        token: _token,
        'Accept': 'application/vnd.github.v3+json'
      }
    );
    _http = new Dio(options);
    // _http.interceptors.add(InterceptorsWrapper(
    //   onResponse: (Response response) {
    //     return response;
    //   }
    // ));
    // gist = {
    //   'getGistInfo': (id) => _http.get('/gists/$id'),
    //   'updateGistInfo': (id, data) => _http.patch('/gists/$id', data: data)
    // };

    gist = new _Gist(_http);
  }

  Future<Response> login () {
    return _http.get('https://api.github.com');
  }
}

class _Gist {
  final Dio http;
  _Gist(this.http);

  getGistInfo (id) => http.get('/gists/$id');

  updateGistInfo (id, data) => http.patch('/gists/$id', data: data);
}