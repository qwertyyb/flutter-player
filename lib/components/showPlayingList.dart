import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './SongListItem.dart';
import '../providers/playing.dart';

showPlayingList (BuildContext context) {
  Playing playing = Provider.of<Playing>(context);
  showModalBottomSheet(
    context: context,
    builder: (BuildContext ctx) => Container(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(border: Border(bottom: BorderSide(width:0.5, color: Colors.black26))),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              child: Text('播放列表', style: TextStyle(fontSize: 18))
            )
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (BuildContext itemCtx, index) {
                return index < playing.list.length ? SongListItem(song: playing.list[index], toPlayer: false,) : null;
              },
            )
          )
        ]
      ),
    )
  );
}
