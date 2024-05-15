import './song.dart';

class Playlist {
  final String name;
  final String owner;
  final List<Song> items;

  Playlist(this.name, this.owner, this.items);
}