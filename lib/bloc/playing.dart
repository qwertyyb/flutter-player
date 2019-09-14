import 'dart:math' as Math;
import 'package:flutter_learn/bloc/BlocProvider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/song.dart';

enum PlayMode {
  Single,
  SingleLoop,
  ListLoop,
  ListOrder,
  Random
}

class PlayingSongBLoC implements BlocBase {
  Song _song = new Song(
    id: 1,
    title: '灯花佐酒',
    artists: '河图',
    album: '灯花佐酒',
    cover: 'https://y.gtimg.cn/music/photo_new/T002R800x800M0000002WzhX07r0ew.jpg?max_age=2592000',
    url: 'http://cdn.qwertyyb.cn/audio/河图-灯花佐酒.mp3'
  );
  Duration _duration = Duration(seconds: 100);
  Duration _position = Duration(seconds: 0);
  AudioPlayerState _state = AudioPlayerState.PAUSED;
  List<Song> _list = <Song>[];
  PlayMode _mode = PlayMode.ListLoop;

  bool _seeking = false;

  AudioPlayer _player = new AudioPlayer();

  var _songSubject = BehaviorSubject<Song>();
  var _durationSubject = BehaviorSubject<Duration>();
  var _positionSubject = BehaviorSubject<Duration>();
  var _stateSubject = BehaviorSubject<AudioPlayerState>();
  var _modeSubject = BehaviorSubject<PlayMode>();
  BehaviorSubject<List<Song>> _listSubject = BehaviorSubject<List<Song>>();

  Stream<Song> get stream => _songSubject.stream;
  Stream<Duration> get durationStream => _durationSubject.stream;
  Stream<Duration> get positionStream => _positionSubject.stream;
  Stream<AudioPlayerState> get stateStream => _stateSubject.stream;
  Stream<List<Song>> get listStream => _listSubject.stream;
  Stream<PlayMode> get modeStream => _modeSubject.stream; 

  Song get song => _song;
  Duration get duration => _duration;
  Duration get position => _position;
  AudioPlayerState get state => _state;
  List<Song> get list => _list;

  PlayingSongBLoC () {
    _listSubject.add(<Song>[_song]);
    _player.onDurationChanged.listen((Duration d) {
      _duration = d;
      _durationSubject.add(d);
    });
    _player.onAudioPositionChanged.listen((Duration p) {
      if (!_seeking) {
        _position = position;
        _positionSubject.add(p);
      }
    });
    _player.onPlayerStateChanged.listen((AudioPlayerState state) {
      if (AudioPlayerState.COMPLETED == state) {
        switch (_mode) {
          case PlayMode.SingleLoop:
            return play();
          case PlayMode.ListLoop:
            return next();
          case PlayMode.ListOrder:
            var curIndex = _list.indexOf(_song);
            if (curIndex != -1 && curIndex != _list.length) {
              return next();
            }
            break;
          case PlayMode.Random:
            int nextIndex = Math.Random().nextInt(_list.length);
            return play(_list[nextIndex]);
          case PlayMode.Single:
            break;
        }
      }
      _state = state;
      _stateSubject.add(state);
    });
    _player.onPlayerError.listen((msg) {
      _state = AudioPlayerState.PAUSED;
      _stateSubject.add(AudioPlayerState.PAUSED);
    });
  }
  void dispose () {
    _songSubject.close();
    _durationSubject.close();
    _positionSubject.close();
    _stateSubject.close();
  }

  togglePlayPause () async {
    _state == AudioPlayerState.PLAYING ? _player.pause() : _player.play(_song.url);
  }

  play ([Song song]) async {
    song = song == null ? _song : song;
    _song = song;
    _songSubject.add(song);
    await _player.stop();
    _player.play(song.url);
  }

  pause () async {
    var result = await _player.pause();
    if (result == 1) _stateSubject.add(AudioPlayerState.PAUSED);
  }

  seek (int value) async {
    _seeking = false;
    await _player.seek(Duration(milliseconds: value));
  }
  startSeek (int value) async {
    _seeking = true;
    _positionSubject.add(Duration(milliseconds: value));
  }

  setList (List<Song> list) {
    _list = list;
    _listSubject.add(list);
  }

  prev () {
    int playingIndex = _list.indexOf(_song);
    if (playingIndex != -1) {
      int prevIndex = playingIndex > 1 ? playingIndex - 1 : _list.length;
      play(_list[prevIndex]);
    }
  }

  next () {
    int playingIndex = _list.indexOf(_song);
    if (playingIndex != -1) {
      int nextIndex = playingIndex >= _list.length - 1 ? 0 : playingIndex + 1;
      play(_list[nextIndex]);
    }
  }

  updatePlayMode () {
    var mode = _mode == PlayMode.ListLoop ? PlayMode.SingleLoop :
           _mode == PlayMode.SingleLoop ? PlayMode.Random :
           _mode == PlayMode.Random ? PlayMode.ListOrder : 
           _mode == PlayMode.ListOrder ? PlayMode.Single : PlayMode.ListLoop;
    _mode = mode;
    _modeSubject.add(mode);
  }
}

