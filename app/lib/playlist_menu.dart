import 'package:flutter/material.dart';

import 'package:app/interfaces/playlist.dart';

class PlaylistMenu extends StatelessWidget {
  const PlaylistMenu({super.key, required this.playlists});

  final List<Playlist> playlists;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Playlists'),
        for (final playlist in playlists) PlaylistItem(playlist: playlist),
      ],
    );
  }
}

class PlaylistItem extends StatelessWidget {
  const PlaylistItem({super.key, required this.playlist});

  final Playlist playlist;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(playlist.name),
      subtitle: Text(playlist.owner),
    );
  }
}