class Song {
  final String id;
  final String title;
  final String artist;
  final String album;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      album: json['album'],
    );
  }
}