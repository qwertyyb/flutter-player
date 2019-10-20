import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song.dart';
import '../providers/playing.dart';

// 歌曲列表项
class SongListItem extends StatelessWidget {

  final Song song;
  final bool toPlayer;
  final VoidCallback onPlay;

  SongListItem ({this.song, this.toPlayer = true, this.onPlay });

  @override
  Widget build(BuildContext context) {
    Playing playing = Provider.of<Playing>(context);

    return InkWell(
      onTap: () {
        playing.play(song);
        if (toPlayer) {
          Navigator.pushNamed(context, '/player');
        }
        if (onPlay != null) onPlay();
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[Container(
          width: 3.0,
          height: 40,
          color: playing.song.id == song.id ? Theme.of(context).primaryColor : Colors.transparent,
          margin: EdgeInsets.only(right: 16.0)
        ),
        Expanded(child: Container(
          padding: EdgeInsets.only(top: 2.0, bottom: 2.0, right: 10.0),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black12))
          ),
          child: Row(children: <Widget>[
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child:Text(song.title, style: TextStyle(fontSize: 16, color: playing.song.id == song.id ? Theme.of(context).primaryColor : Colors.black))
                ),
                Text(song.artists + ' - ' + song.album,
                  style: TextStyle(color: playing.song.id == song.id ? Theme.of(context).primaryColor : Colors.black45, fontSize: 12)
                )
              ],
            )),
            IconButton(
              icon: Icon(Icons.more_horiz), iconSize: 20,
              color: playing.song.id == song.id ? Theme.of(context).primaryColor : Colors.black,
              onPressed: () {},
            )
          ])
        ))
      ],),
    );
  }
}
