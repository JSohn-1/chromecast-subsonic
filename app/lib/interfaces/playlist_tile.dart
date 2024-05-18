class PlaylistTile {
  final String name;
  final String owner;
  final String id;

  PlaylistTile({required this.name, required this.owner, required this.id});

  factory PlaylistTile.fromJson(Map<String, dynamic> json) {
    return PlaylistTile(
      name: json['name'],
      owner: json['owner'],
      id: json['id'],
    );
  }
}