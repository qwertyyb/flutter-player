import 'package:flutter/material.dart';
import './SongListItem.dart';
import '../bloc/playing.dart';

showPlayingList (BuildContext context) {
  PlayingSongBLoC bloc = PlayingSongProvider.bLoc;
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
              child: Text('播放列表', style: TextStyle(fontSize: 24))
            )
          ),
          Expanded(
            child: StreamBuilder(
            stream: bloc.listStream,
            builder: (BuildContext listCtx, sp) => ListView.builder(
              itemBuilder: (BuildContext itemCtx, index) {
                return sp.data != null && index < sp.data.length ? SongListItem(song: sp.data[index], toPlayer: false,) : null;
              },
            )
          ))
        ]
      ),
    )
  );
}
