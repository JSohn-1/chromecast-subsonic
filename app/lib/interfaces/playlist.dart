import './song.dart';

class Playlist {
  final String name;
  final String owner;
  final String comment;
  final String id;
  final List<Song> songs;
  

  Playlist({required this.name, required this.owner, required this.comment, required this.id, required this.songs});

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      name: json['name'],
      owner: json['owner'],
      comment: json['comment'],
      id: json['id'],
      songs: (json['entry'] as List).map((song) => Song.fromJson(song)).toList(),
    );
  }
}