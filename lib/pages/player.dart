import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_learn/bloc/BlocProvider.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import '../bloc/playing.dart';
import '../utils.dart';
import '../components/showPlayingList.dart';

class _Title extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    PlayingSongBLoC bloc = BlocProvider.of<PlayingSongBLoC>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        GestureDetector(
          child: Icon(Icons.arrow_back, size: 32, color: Colors.white),
          onTap: () => {
            Navigator.canPop(context) && Navigator.pop(context)
          }
        ),
        Expanded(child: Center(
          child: StreamBuilder(
            stream: bloc.stream,
            initialData: bloc.song,
            builder: (context, snapshot) => Text(
              snapshot.data.title,
              style: TextStyle(
                fontSize: 24, color: Colors.white, fontWeight: FontWeight.normal,
                decoration: TextDecoration.none,
              )
            )
          )
        )),
        Icon(Icons.more_horiz, size: 32, color: Colors.white,)
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
          Container(height: 2, width: 32, color: Colors.white),
          Padding(
            child: Text(text, style: TextStyle(fontSize: 18, color: Colors.white),),
            padding: EdgeInsets.symmetric(horizontal: 10)
          ),
          Container(height: 2, width: 32, color: Colors.white),
        ]
      )
    );
  }
}

class _Cover extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    PlayingSongBLoC bloc = BlocProvider.of<PlayingSongBLoC>(context);

    return AspectRatio(aspectRatio: 1, child: Container(
      // margin: EdgeInsets.only(left: 20, right: 20, top: 40, bottom: 40),
      // width: MediaQuery.of(context).size.width - 80,
      // height: MediaQuery.of(context).size.width - 80,
      child: StreamBuilder(
        stream: bloc.stream,
        initialData: bloc.song,
        builder: (context, snapshot) => ClipOval(
          child: CachedNetworkImage(
            placeholder: (ctx, url) => Image.memory(kTransparentImage),
            imageUrl: snapshot.data.cover
          )
        )
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromARGB(15, 0, 0, 0), width: 20),
        borderRadius: BorderRadius.circular(800)
      )
    ),);
  }
}

class _DurationBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    PlayingSongBLoC bloc = BlocProvider.of<PlayingSongBLoC>(context);
    return StreamBuilder(
      stream: bloc.durationStream,
      initialData: bloc.duration,
      builder: (context, ds) => StreamBuilder(
        stream: bloc.positionStream,
        initialData: bloc.position,
        builder: (context, ps) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(formatDuration(ps.data as Duration),
              style: TextStyle(fontSize: 16, color: Colors.white)),
            Expanded(child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: Slider(
                  min: 0,
                  max: ((ds.data as Duration).inMilliseconds + 3000).toDouble(),
                  value: ps.data.inMilliseconds.toDouble(),
                  onChanged: (double value) => { bloc.startSeek(value.toInt()) },
                  onChangeEnd: (double value) => { bloc.seek(value.toInt()) },
                  inactiveColor: Colors.white70,
                  activeColor: Theme.of(context).primaryColor,
                ),
              ),
            )),
            Text(formatDuration(ds.data as Duration), style: TextStyle(fontSize: 16, color: Colors.white))
          ],
        )
      )
    );
  }
}

class _Actions extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    PlayingSongBLoC bloc = BlocProvider.of<PlayingSongBLoC>(context);

    return Container(
      margin: EdgeInsets.only(top: 20),
      // height: 180,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Container(
                child: StreamBuilder(
                  stream: bloc.modeStream,
                  builder: (BuildContext ctx, sp) {
                    var mode = sp.data as PlayMode;
                    var icon = mode == PlayMode.ListLoop ? Icons.repeat :
                              mode == PlayMode.SingleLoop ? Icons.repeat_one :
                              mode == PlayMode.Random ? Icons.shuffle :
                              mode == PlayMode.Single ? Icons.trending_flat : Icons.list;
                    return IconButton(
                      icon: Icon(icon),
                      iconSize: 30,
                      color: Colors.white,
                      onPressed: bloc.updatePlayMode,
                    );
                  }
                ),
                padding: EdgeInsets.all(5),
              ),
              Container(
                child: IconButton(
                  icon: Icon(Icons.skip_previous),
                  iconSize: 30,
                  color: Colors.white,
                  onPressed: bloc.prev,
                ),
                decoration: BoxDecoration(
                  border: Border.all(width: 2, color: Colors.white),
                  borderRadius: BorderRadius.circular(800)
                ),
              ),
              Container(
                child: StreamBuilder(
                  stream: bloc.stream,
                  initialData: bloc.song,
                  builder: (ctx, ss) => StreamBuilder(
                    stream: bloc.stateStream,
                    initialData: bloc.state,
                    builder: (ctx, snapshot) => IconButton(
                      icon: (snapshot.data as AudioPlayerState) == AudioPlayerState.PLAYING ? Icon(Icons.pause) : Icon(Icons.play_arrow),
                      iconSize: 48,
                      color: Colors.white,
                      onPressed: bloc.togglePlayPause,
                    )
                  )
                ),
                decoration: BoxDecoration(
                  border: Border.all(width: 2, color: Colors.white),
                  borderRadius: BorderRadius.circular(800)
                )
              ),
              Container(
                child: IconButton(
                  icon: Icon(Icons.skip_next),
                  iconSize: 30,
                  color: Colors.white,
                  onPressed: bloc.next,
                ),
                decoration: BoxDecoration(
                  border: Border.all(width: 2, color: Colors.white),
                  borderRadius: BorderRadius.circular(800)
                ),
              ),
              Container(
                child: IconButton(
                  icon: Icon(Icons.queue_music),
                  iconSize: 30,
                  color: Colors.white,
                  onPressed: () { showPlayingList(context); },
                ),
                padding: EdgeInsets.all(5),
              ),
            ],
          ),
          Padding(padding: EdgeInsets.only(top: 10), child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.favorite_border, color: Colors.white, size: 30)
              ),
              IconButton(
                onPressed: () {
                  getExternalStorageDirectory().then((Directory root) {
                    return new Directory('${root.path}/music');
                  }).then((dict) {
                    print('123');
                    print(dict.path);
                    return dict.exists().then((exist) {
                      if (exist) {
                        return dict.path;
                      }
                      dict.createSync();
                      return dict.path;
                    });
                  }).then((path) {
                    return FlutterDownloader.enqueue(
                      url: bloc.song.url,
                      fileName: '${bloc.song.artists}-${bloc.song.title}',
                      savedDir: path
                    );
                  }).then((taskId) {
                    showToast('正在下载...');
                  }).catchError((err) {
                    print(err);
                    showToast('下载失败');
                  });
                },
                icon: Icon(Icons.cloud_download, color: Colors.white, size: 30,)
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.share, color: Colors.white, size: 30,)
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.timer, color: Colors.white, size: 30,)
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
    PlayingSongBLoC bloc = BlocProvider.of<PlayingSongBLoC>(context);

    return SafeArea(top: false,
      child: Material(child: StreamBuilder(
        stream: bloc.stream,
        initialData: bloc.song,
        builder: (BuildContext ctx, sp) => DecoratedBox(
          // color: Colors.red,
          decoration: Decoration.lerp(BoxDecoration(
            image: DecorationImage(
              image: new CachedNetworkImageProvider(bloc.song.cover),
              fit: BoxFit.cover
            )
          ), BoxDecoration(
            color: Colors.black87,
          ), 0.35),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaY: 10, sigmaX: 200),
            child: Container(
              padding: EdgeInsets.all(10),
              color: Colors.black54.withOpacity(.4),
              child: SafeArea(child: StreamBuilder(
                stream: bloc.stream,
                initialData: bloc.song,
                builder: (BuildContext ctx, sp) => Column(
                  children: <Widget>[
                    _Title(),
                    _SubTitle(sp.data.artists),
                    Expanded(child: Padding(padding: EdgeInsets.all(30), child: Center(child: _Cover()),),),
                    _DurationBar(),
                    _Actions()
                  ],
                )
              )
            ))
          )))
      )
    );
  }
}


class PlayerPage extends StatefulWidget {

  @override
  _PlayerPageState createState() => _PlayerPageState();
}