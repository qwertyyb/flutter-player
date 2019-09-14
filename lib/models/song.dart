import 'package:json_annotation/json_annotation.dart';

part 'song.g.dart';

@JsonSerializable(nullable: false)
class Song {
  int id;
  String title;
  String url;
  String cover;
  String album;
  String artists;
  String lyrics;

  Song({this.id, this.title, this.url, this.cover, this.album, this.artists, this.lyrics});

  factory Song.fromJson(Map<String, dynamic> json) => _$SongFromJson(json);
  Map<String, dynamic> toJson() => _$SongToJson(this);
}