import 'package:rxdart/rxdart.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

class DownloadBLoC {
  BehaviorSubject _downloadSubject = BehaviorSubject();

  add (url, { String fileName }) {
    FlutterDownloader.enqueue(
      url: url,
      fileName: fileName,
      savedDir: '/download/'
    );
  }
}