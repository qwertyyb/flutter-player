import 'package:flutter_learn/bloc/BlocProvider.dart';
import 'package:rxdart/rxdart.dart';
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

class SonglistBLoC implements BlocBase {
  Map<String, BehaviorSubject<Pager>> pagerMap = {
    "favorite": BehaviorSubject<Pager>()
  };
  Map<String, BehaviorSubject<List<Song>>> listMap = {
    "favorite": BehaviorSubject<List<Song>>()
  };

  getList({String type = "favorite"}) async {
    Pager pager = Pager(offset: 0, limit: 10, total: 100, loading: true);
    pagerMap[type].add(pager);
    Response response = await Service.getList(1, 10);
    var list = List<Song>.from(response.data["list"].map((item) => Song.fromJson(item)));
    listMap[type].add(list);
    pager = Pager(
      offset: response.data["offset"],
      limit: response.data["limit"],
      total: response.data["total"],
      loading: false);
    pagerMap[type].add(pager);
  }

  @override
  void dispose () {
    listMap.values.map((subject) => subject.close());
  }
}
