import 'package:flutter/material.dart';
import 'package:flutter_learn/bloc/BlocProvider.dart';
import '../models/song.dart';
import '../bloc/playing.dart';

// 歌曲列表项
class SongListItem extends StatelessWidget {

  final Song song;
  final bool toPlayer;
  final VoidCallback onPlay;

  SongListItem ({this.song, this.toPlayer = true, this.onPlay });

  @override
  Widget build(BuildContext context) {
    PlayingSongBLoC bloc = BlocProvider.of<PlayingSongBLoC>(context);

    return InkWell(
      onTap: () {
        bloc.play(song);
        if (toPlayer) {
          Navigator.pushNamed(context, '/player');
        }
        if (onPlay != null) onPlay();
      },
      child: StreamBuilder(
        stream: bloc.stream,
        initialData: bloc.song,
        builder: (ctx, ss) {
          bool active = song.id == ss.data.id;
          Color textColor = active ? Theme.of(context).primaryColor : Colors.black;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[Container(
              width: 5.0,
              height: 40,
              color: active ? Theme.of(context).primaryColor : Colors.transparent,
              margin: EdgeInsets.only(right: 16.0)
            ),
            Expanded(child: Container(
              padding: EdgeInsets.only(top: 4.0, bottom: 4.0, right: 10.0),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black12))
              ),
              child: Row(children: <Widget>[
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(bottom: 3),
                      child:Text(song.title, style: TextStyle(fontSize: 18, color: textColor))
                    ),
                    Text(song.artists + ' - ' + song.album,
                      style: TextStyle(color: active ? Theme.of(context).primaryColor : Colors.black54, fontSize: 12)
                    )
                  ],
                )),
                IconButton(
                  icon: Icon(Icons.more_horiz), iconSize: 20,
                  color: textColor,
                  onPressed: () {},
                )
              ])
            ))
          ],
        );
      })
    );
  }
}
