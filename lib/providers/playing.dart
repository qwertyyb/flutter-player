import 'dart:math' as Math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../models/song.dart';


enum PlayMode {
  Single,
  SingleLoop,
  ListLoop,
  ListOrder,
  Random
}

class Playing with ChangeNotifier {
  Song song = new Song(
    id: 1,
    title: '灯花佐酒',
    artists: '河图',
    album: '灯花佐酒',
    cover: 'https://y.gtimg.cn/music/photo_new/T002R800x800M0000002WzhX07r0ew.jpg?max_age=2592000',
    url: 'https://cdn.qwertyyb.cn/audio/河图-灯花佐酒.mp3'
  );
  Duration duration = Duration(seconds: 100);
  Duration position = Duration(seconds: 0);
  AudioPlayerState state = AudioPlayerState.PAUSED;
  PlayMode mode = PlayMode.ListLoop;
  List<Song> list = <Song>[];

  AudioPlayer _player = new AudioPlayer();

  Playing() {
    list.add(song);
    _player.setUrl(Uri.encodeFull(song.url));
    _player.setReleaseMode(ReleaseMode.STOP);
    _player.onDurationChanged.listen((Duration d) {
      duration = d;
      notifyListeners();
    });
    _player.onAudioPositionChanged.listen((Duration p) {
      position = p;
      notifyListeners();
    });
    _player.onPlayerStateChanged.listen((AudioPlayerState _state) {
      if (AudioPlayerState.COMPLETED == _state) {
        switch (mode) {
          case PlayMode.SingleLoop:
            return play();
          case PlayMode.ListLoop:
            return next();
          case PlayMode.ListOrder:
            var curIndex = list.indexOf(song);
            if (curIndex != -1 && curIndex != list.length) {
              return next();
            }
            break;
          case PlayMode.Random:
            int nextIndex = Math.Random().nextInt(list.length);
            return play(list[nextIndex]);
          case PlayMode.Single:
            break;
        }
      }
      state = _state;
    });
    _player.onPlayerError.listen((msg) {
      state = AudioPlayerState.PAUSED;
      notifyListeners();
    });
  }

  togglePlayPause () async {
    state == AudioPlayerState.PLAYING ? _player.pause() : _player.resume();
    notifyListeners();
  }

  updatePlayMode () {
    mode = mode == PlayMode.ListLoop ? PlayMode.SingleLoop :
           mode == PlayMode.SingleLoop ? PlayMode.Random :
           mode == PlayMode.Random ? PlayMode.ListOrder : 
           mode == PlayMode.ListOrder ? PlayMode.Single : PlayMode.ListLoop;
    notifyListeners();
  }

  prev () {
    int playingIndex = list.indexOf(song);
    if (playingIndex != -1) {
      int prevIndex = playingIndex > 1 ? playingIndex - 1 : list.length;
      play(list[prevIndex]);
    }
    notifyListeners();
  }

  next () {
    int playingIndex = list.indexOf(song);
    if (playingIndex != -1) {
      int nextIndex = playingIndex >= list.length - 1 ? 0 : playingIndex + 1;
      play(list[nextIndex]);
    }
    notifyListeners();
  }

  play ([Song _song]) async {
    song = _song == null ? song : _song;
    await _player.stop();
    _player.play(Uri.encodeFull(_song.url));
    notifyListeners();
  }

  pause () async {
    var result = await _player.pause();
    if (result == 1) state = AudioPlayerState.PAUSED;
    notifyListeners();
  }

  seek (int value) async {
    await _player.seek(Duration(milliseconds: value));
    notifyListeners();
  }

  updateList (List<Song> _list) {
    list = _list;
    notifyListeners();
  }
}

