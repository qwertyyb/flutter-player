import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../github/github.dart';
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
  GithubClient _githubClient;

  List<Song> favoriteList = [];
  bool loading = false;

  _HomePageState () {
    _githubClient = new GithubClient(token: '');
    this.getList();
  }

  getList () async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String gistID = prefs.getString('prefs/gistID');
    if (gistID == null) return null;
    Response result = await _githubClient.gist.getGistInfo(gistID);
    Map<String, dynamic> files = result.data['files'];
    Map<String, dynamic> file = files['favorite.json'];
    Map<String, dynamic> json = jsonDecode(file['content']);
    List<Song> list = new List<Song>.from(json['list'].map((item) => new Song(
        id: item['id'].toString(),
        albumName: item['album'],
        artists: new List<String>.from(item['artists']),
        title: item['title'],
        coverUrl: item['cover'],
        lyrics: '',
        urls: new Map<String, String>.from(item['urls'])
      )).toList());
    PlayingSongProvider.bLoc.setList(list);
    if (widget.list == null) {
      setState(() {
        favoriteList = list;
        loading = false;
      });
    }
    return json;
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
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
      ) : ListView.builder(
          itemBuilder: (BuildContext ctx, int index) {
            var list = widget.list == null ? favoriteList : widget.list;
            if (index < list.length) {
              return SongListItem(song: list[index]);
            }
            return null;
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
    GithubClient githubClient = new GithubClient(token: ' ');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String gistID = prefs.getString('prefs/gistID');
    if (gistID == null) return;
    Response r = await githubClient.gist.getGistInfo(gistID);
    Map<String, dynamic> files = r.data['files'];
    Map<String, dynamic> obj = json.decode(files['_meta.json']['content']);
    setState(() {
      categoryList = obj['category_list'].map((category) {
        var file = json.decode(files[category['file']]['content']);
        category['content'] = new List<Song>.from(file['list'].map((item) => new Song(
          id: item['id'].toString(),
          albumName: item['album'],
          artists: new List<String>.from(item['artists']),
          title: item['title'],
          coverUrl: item['cover'],
          lyrics: '',
          urls: new Map<String, String>.from(item['urls'])
        )).toList());
        return category;
      }).toList();
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
    PlayingSongBLoC bloc = PlayingSongProvider.of(context);

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
                    imageUrl: (snapshot.data as Song).coverUrl,
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
                  String subTitle = _song.artists.join('/') + ' - ' + _song.albumName;
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
