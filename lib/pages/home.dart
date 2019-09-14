import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_learn/bloc/BlocProvider.dart';
import 'package:flutter_learn/bloc/list.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/song.dart';
import '../bloc/playing.dart';
import '../components/showPlayingList.dart';
import '../components/SongListItem.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title, this.list}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final List<Song> list;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool loading = true;

  @override
  void initState(){
    super.initState();
    this.getList();
  }

  getList() async {
    SonglistBLoC songlistBLoC = BlocProvider.of<SonglistBLoC>(context);
    await songlistBLoC.getList(type: "favorite");
    setState((){
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    SonglistBLoC songlistBLoC = BlocProvider.of<SonglistBLoC>(context);
    PlayingSongBLoC playingBloc = BlocProvider.of<PlayingSongBLoC>(context);
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: loading ? Center(
        child: CircularProgressIndicator(),
      ) : StreamBuilder<List<Song>>(
          stream: songlistBLoC.listMap["favorite"],
          builder: (BuildContext context, AsyncSnapshot<List<Song>> snapshot) {
            List<Song> list = snapshot.data;
            return ListView.builder(
              itemBuilder: (BuildContext ctx, int index) {
                if (list != null && index < list.length) {
                  return SongListItem(
                    song: list[index],
                    onPlay: () {
                      playingBloc.setList(list);
                    },
                  );
                }
                return null;
              }
            );
          }
        ),
      bottomNavigationBar: PlayerBar(),
      drawer: _Drawer()
    );
  }
}

class _Drawer extends StatefulWidget {
  @override
  _DrawerState createState() => _DrawerState();
}

class _DrawerState extends State<_Drawer> {
  @override
  void initState() {
    super.initState();
    _getList();
  }
  bool loading = true;
  List categoryList = [];

  _getList() async {
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(padding: EdgeInsets.only(top: 24), child: Column(children: <Widget>[
        loading ? Container(
          padding: EdgeInsets.only(top: 60),
          child: CircularProgressIndicator()
        ) : Container(),
        Expanded(child: Column(children: categoryList.map((category) => InkWell(
          onTap: () {
            Navigator.of(context).pushNamedAndRemoveUntil('/list',
              (_) => false,
              arguments: { 'title': category['name'], 'list': category['content'] }
            );
          },
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: CachedNetworkImage(
                  placeholder: (_, __) => Image.memory(kTransparentImage),
                  imageUrl: category['icon'],
                  width: 30,
                  height: 30,
                ),
              ),
              Text(category['name'], style: TextStyle(fontSize: 18)),
            ]
          ),),).toList(),),),
        ListTile(
          leading: const Icon(Icons.cloud_download, size: 24,),
          title: const Text('下载', style: TextStyle(color: Colors.black, fontSize: 20),),
          onTap: () {
            Navigator.of(context).pushNamed('/download');
          },
        ),
        ListTile(
          dense: true,
          leading: const Icon(Icons.settings, size: 24,),
          title: const Text('设置', style: TextStyle(color: Colors.black, fontSize: 20),),
          onTap: () {
            Navigator.of(context).pushNamed('/preferences');
          },
        ),
      ],),
    ),);
  }
}

// 歌曲播放条
class PlayerBar extends StatelessWidget {

  @override
  Widget build (BuildContext context) {
    PlayingSongBLoC bloc = BlocProvider.of<PlayingSongBLoC>(context);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/player');
      },
      child: Container(
        padding: EdgeInsets.only(left: 10, right: 10),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey)
          )
        ),
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 10),
              width: 40,
              height: 40,
              child: ClipOval(
                child: StreamBuilder(
                  stream: bloc.stream,
                  initialData: bloc.song,
                  builder: (context, snapshot) => CachedNetworkImage(
                    width: 40,
                    height: 40,
                    imageUrl: (snapshot.data as Song).cover,
                    placeholder: (ctx, url) => Image.memory(kTransparentImage),
                  ),
                ),
              )
            ),
            Expanded(
              child: StreamBuilder(
                stream: bloc.stream,
                initialData: bloc.song,
                builder: (context, snapshot) {
                  Song _song = snapshot.data as Song;
                  String subTitle = _song.artists + ' - ' + _song.album;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(_song.title),
                      Text(subTitle, style: TextStyle(fontSize: 12),)
                    ]
                  );
                }
              )
            ),
            StreamBuilder(
              stream: bloc.stateStream,
              initialData: bloc.state,
              builder: (context, snapshot) => IconButton(
                color: Theme.of(context).primaryColor,
                iconSize: 32,
                icon: snapshot.data == AudioPlayerState.PAUSED ? Icon(Icons.play_circle_outline) : Icon(Icons.pause_circle_outline),
                onPressed: () {
                  bloc.togglePlayPause();
                },
              ),
            ),
            IconButton(
              color: Theme.of(context).primaryColor,
              iconSize: 32,
              icon: Icon(Icons.list),
              onPressed: () => showPlayingList(context),
            ),
          ]
        )
      )
    );
  }
}
