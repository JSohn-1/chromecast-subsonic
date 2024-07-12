class PlaybackLocation {
  final String name;
  final String id;

  PlaybackLocation({required this.name, required this.id});

  factory PlaybackLocation.fromJson(Map<String, dynamic> json) {
    return PlaybackLocation(
      name: json['name'],
      id: json['id'],
    );
  }
}