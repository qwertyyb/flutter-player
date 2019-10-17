import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import '../providers/playing.dart';
import 'package:path_provider/path_provider.dart';
import '../utils.dart';
import '../components/showPlayingList.dart';

class _Title extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        GestureDetector(
          child: Icon(Icons.arrow_back, size: 20, color: Colors.white),
          onTap: () {
            Navigator.canPop(context) && Navigator.pop(context);
          }
        ),
        Expanded(child: Center(
          child: Selector<Playing, String>(
              selector: (_, playing) => playing.song.title,
              builder: (_, title, __) => Text(
                title,
                style: TextStyle(
                  fontSize: 16, color: Colors.white, fontWeight: FontWeight.normal,
                  decoration: TextDecoration.none,
              ),
            ),
            
          )
        ),),
        Icon(Icons.more_horiz, size: 20, color: Colors.white,)
      ],
    );
  }
}

class _SubTitle extends StatelessWidget {
  final String text;

  _SubTitle(this.text, { Key key }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(height: 1, width: 32, color: Colors.grey),
          Padding(
            child: Text(text, style: TextStyle(fontSize: 14, color: Colors.grey[200]),),
            padding: EdgeInsets.symmetric(horizontal: 10)
          ),
          Container(height: 1, width: 32, color: Colors.grey),
        ]
      )
    );
  }
}

class _Cover extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return AspectRatio(aspectRatio: 1, child: Container(
      // margin: EdgeInsets.only(left: 20, right: 20, top: 40, bottom: 40),
      // width: MediaQuery.of(context).size.width - 80,
      // height: MediaQuery.of(context).size.width - 80,
      child: ClipOval(
        child: Selector<Playing, String>(
          selector: (_, playing) => playing.song.cover,
          builder: (_, cover, __) => CachedNetworkImage(
            placeholder: (ctx, url) => Image.memory(kTransparentImage),
            imageUrl: cover
          ),
        ),
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromARGB(15, 0, 0, 0), width: 20),
        borderRadius: BorderRadius.circular(800)
      )
    ),);
  }
}

class DurationBar extends StatefulWidget {

  @override
  DurationBarState createState() => DurationBarState();
}


class DurationBarState extends State<DurationBar> {
  bool seeking = false;
  double seekingValue = 0.0;
  seek (value) {
    setState(() {
      seeking = true;
      seekingValue = value;
    });
  }
  @override
  Widget build(BuildContext context) {
    Playing playing = Provider.of<Playing>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(formatDuration(playing.position),
          style: TextStyle(fontSize: 12, color: Colors.white)),
        Expanded(child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Slider(
              min: 0,
              max: (playing.duration.inMilliseconds + 3000).toDouble(),
              value: seeking ? seekingValue : playing.position.inMilliseconds.toDouble(),
              onChanged: seek,
              onChangeEnd: (double value) { playing.seek(value.toInt()); setState((){ seeking = false; }); },
              inactiveColor: Colors.white70,
              activeColor: Theme.of(context).primaryColor,
            ),
          ),
        )),
        Text(formatDuration(playing.duration), style: TextStyle(fontSize: 12, color: Colors.white))
      ],
    );
  }
}


class _Actions extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    Playing playing = Provider.of<Playing>(context);

    var mode = playing.mode;
    var icon = mode == PlayMode.ListLoop ? Icons.repeat :
              mode == PlayMode.SingleLoop ? Icons.repeat_one :
              mode == PlayMode.Random ? Icons.shuffle :
              mode == PlayMode.Single ? Icons.trending_flat : Icons.list;
    return Container(
      margin: EdgeInsets.only(top: 0),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Container(
                child: IconButton(
                  icon: Icon(icon),
                  iconSize: 20,
                  color: Colors.grey[400],
                  onPressed: playing.updatePlayMode,
                ),
                padding: EdgeInsets.all(5),
              ),
              Container(
                width: 36,
                height: 36,
                child: IconButton(
                  icon: Icon(Icons.skip_previous),
                  iconSize: 18,
                  color: Colors.white,
                  onPressed: playing.prev,
                ),
                decoration: BoxDecoration(
                  border: Border.all(width: 2, color: Colors.white),
                  borderRadius: BorderRadius.circular(800)
                ),
              ),
              Container(
                child: IconButton(
                    icon: playing.state == AudioPlayerState.PLAYING ? Icon(Icons.pause) : Icon(Icons.play_arrow),
                    iconSize: 30,
                    color: Colors.white,
                    onPressed: playing.togglePlayPause,
                ),
                decoration: BoxDecoration(
                  border: Border.all(width: 2, color: Colors.white),
                  borderRadius: BorderRadius.circular(800)
                )
              ),
              Container(
                width: 36,
                height: 36,
                child: IconButton(
                  icon: Icon(Icons.skip_next),
                  iconSize: 18,
                  color: Colors.white,
                  onPressed: playing.next,
                ),
                decoration: BoxDecoration(
                  border: Border.all(width: 2, color: Colors.white),
                  borderRadius: BorderRadius.circular(800)
                ),
              ),
              Container(
                child: IconButton(
                  icon: Icon(Icons.queue_music),
                  iconSize: 20,
                  color: Colors.grey[400],
                  onPressed: () { showPlayingList(context); },
                ),
                padding: EdgeInsets.all(5),
              ),
            ],
          ),
          Padding(padding: EdgeInsets.only(top: 0), child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.favorite_border, color: Colors.grey[400], size: 20)
              ),
              IconButton(
                onPressed: () {
                  getExternalStorageDirectory().then((Directory root) {
                    return new Directory('${root.path}/music');
                  }).then((dict) {
                    return dict.exists().then((exist) {
                      if (exist) {
                        return dict.path;
                      }
                      dict.createSync();
                      return dict.path;
                    });
                  }).then((path) {
                    return FlutterDownloader.enqueue(
                      url: playing.song.url,
                      fileName: '${playing.song.artists}-${playing.song.title}',
                      savedDir: path
                    );
                  }).then((taskId) {
                    showToast('正在下载...');
                  }).catchError((err) {
                    print(err);
                    showToast('下载失败');
                  });
                },
                icon: Icon(Icons.cloud_download, color: Colors.grey[400], size: 20,)
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.share, color: Colors.grey[400], size: 20,)
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.timer, color: Colors.grey[400], size: 20,)
              )
            ],
          ), ),
        ]
      )
    );
  }
}

class _PlayerPageState extends State<PlayerPage> {

  @override
  Widget build(BuildContext context) {
    Playing playing = Provider.of<Playing>(context);

    return SafeArea(top: false,
      child: Material(child: DecoratedBox(
        decoration: Decoration.lerp(BoxDecoration(
          image: DecorationImage(
            image: new CachedNetworkImageProvider(playing.song.cover),
            fit: BoxFit.cover
          )
        ), BoxDecoration(
          color: Colors.black87,
        ), 0.35),
        child: ClipRect(child: BackdropFilter(
          filter: ImageFilter.blur(sigmaY: 10, sigmaX: 10),
          child: Container(
            padding: EdgeInsets.all(10),
            color: Colors.black54.withOpacity(.4),
            child: SafeArea(child: Column(
                children: <Widget>[
                  _Title(),
                  _SubTitle(playing.song.artists),
                  Expanded(child: Padding(padding: EdgeInsets.all(30), child: Center(child: _Cover()),),),
                  DurationBar(),
                  _Actions()
                ],
              ),),
          )
        ),)
      )
    ),);
  }
}


class PlayerPage extends StatefulWidget {

  @override
  _PlayerPageState createState() => _PlayerPageState();
}