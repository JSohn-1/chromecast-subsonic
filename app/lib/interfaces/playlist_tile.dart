class PlaylistTile {
  final String name;
  final String owner;

  PlaylistTile({required this.name, required this.owner});

  factory PlaylistTile.fromJson(Map<String, dynamic> json) {
    return PlaylistTile(
      name: json['name'],
      owner: json['owner'],
    );
  }
}