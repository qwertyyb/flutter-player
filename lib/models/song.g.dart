// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Song _$SongFromJson(Map<String, dynamic> json) {
  return Song(
    id: json['id'] as int,
    title: json['title'] as String,
    url: json['url'] as String,
    cover: json['cover'] as String,
    album: json['album'] as String,
    artists: json['artists'] as String,
    lyrics: json['lyrics'] as String,
  );
}

Map<String, dynamic> _$SongToJson(Song instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'url': instance.url,
      'cover': instance.cover,
      'album': instance.album,
      'artists': instance.artists,
      'lyrics': instance.lyrics,
    };
