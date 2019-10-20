
import 'package:flutter/cupertino.dart';
import '../services/api.dart';
import '../models/song.dart';
import 'package:dio/dio.dart';

class Pager {
  final int offset;
  final int limit;
  final int total;
  final bool loading;

  Pager({this.offset, this.limit, this.total, this.loading = false});
}

class Songlist with ChangeNotifier {
  Map<String, Pager> pagerMap = {
    "favorite": Pager()
  };
  Map<String, List<Song>> listMap = {
    "favorite": List<Song>()
  };

  getList({String type = "favorite"}) async {
    Pager pager = Pager(offset: 0, limit: 10, total: 100, loading: true);
    pagerMap[type] = pager;
    await Future.delayed(Duration(milliseconds: 600));
    Response response = await Service.instance.getList(1, 10);
    var list = List<Song>.from(response.data["list"].map((item) => Song.fromJson(item)));
    /* var list = [
      new Song(
        id: 1, title: '灯花佐酒', artists: '河图', album: '灯花佐酒',
        cover: 'https://y.gtimg.cn/music/photo_new/T002R800x800M0000002WzhX07r0ew.jpg?max_age=2592000',
        url: 'https://cdn.qwertyyb.cn/audio/河图-灯花佐酒.mp3'
      ),
      new Song(
        id: 2, title: '长夜梦我', artists: '河图,汐音社', album: '长夜梦我',
        cover: 'https://y.gtimg.cn/music/photo_new/T002R800x800M0000002WzhX07r0ew.jpg?max_age=2592000',
        url: 'https://cdn.qwertyyb.cn/audio/河图,汐音社-长夜梦我.mp3'
      ),
      new Song(
        id: 3, title: '天光之外', artists: '河图', album: '天光之外',
        cover: 'https://y.gtimg.cn/music/photo_new/T002R800x800M0000002WzhX07r0ew.jpg?max_age=2592000',
        url: 'https://cdn.qwertyyb.cn/audio/河图-天光之外.mp3'
      ),
      new Song(
        id: 4, title: '若某日我封笔', artists: '河图', album: '若某日我封笔',
        cover: 'https://y.gtimg.cn/music/photo_new/T002R800x800M0000002WzhX07r0ew.jpg?max_age=2592000',
        url: 'https://cdn.qwertyyb.cn/audio/河图-若某日我封笔.mp3'
      ),
    ]; */
    listMap[type] = list;
    pager = Pager(
      offset: response.data["offset"],
      limit: response.data["limit"],
      total: response.data["total"],
      loading: false);
    pagerMap[type] = pager;
    notifyListeners();
  }

  @override
  void dispose () {
    super.dispose();
  }
}
