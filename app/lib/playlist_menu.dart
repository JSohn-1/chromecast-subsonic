import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:app/interfaces/playlist_tile.dart';
import 'socket_service.dart';

class PlaylistMenu extends StatefulWidget {
  const PlaylistMenu({super.key});

  @override
  State<PlaylistMenu> createState() => _PlaylistMenuState();
}

class _PlaylistMenuState extends State<PlaylistMenu> {
   List<PlaylistTile> playlists = [];

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    void _loadPlaylists() async {
      final response = await http.get(Uri.parse('${socketService.socket.io.uri}/subsonic/getPlaylists?uuid=${socketService.uuid}'));

      if (response.statusCode == 200) {
        final List<dynamic> playlistsJson = jsonDecode(response.body)['playlists'];
        setState(() {
          playlists = playlistsJson.map((playlistJson) => PlaylistTile.fromJson(playlistJson)).toList();
        });
      }
    }

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

  final PlaylistTile playlist;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(playlist.name),
      subtitle: Text(playlist.owner),
    );
  }
}

