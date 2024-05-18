import 'dart:convert';
import 'dart:ui';

import 'package:app/interfaces/playlist.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:app/interfaces/playlist_tile.dart';
import 'socket_service.dart';

class PlaylistMenu extends StatefulWidget {
  const PlaylistMenu({super.key});

  @override
  State<PlaylistMenu> createState() => _PlaylistMenuState();
}

class _PlaylistMenuState extends State<PlaylistMenu> {
  
    @override
    void initState() {
      super.initState();
      _loadPlaylists();
    }

    Future<void> _loadPlaylists() async {
      await PlaylistTiles.getPlaylists();
      setState(() {});
    }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          color: const Color.fromARGB(20, 255, 255, 255), 
          width: MediaQuery.of(context).size.width, 
          height: 70, 
          child: const Row(
            children: [
              Padding(padding: EdgeInsets.all(10)),
              Text('Playlists', 
                style: TextStyle(
                  fontSize: 24, 
                  color: Colors.white,
                  decoration: TextDecoration.none,
                )
              ),
            ],
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height - 140,
          width: MediaQuery.of(context).size.width,
          child: RefreshIndicator(
            onRefresh: _loadPlaylists,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (final playlist in PlaylistTiles.playlists) Column(
                        children: [
                          const Padding(padding: EdgeInsets.all(10),),
                          PlaylistItem(playlist: playlist),
                        ],
                      ),
                    ],
                  ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PlaylistItem extends StatelessWidget {
  const PlaylistItem({super.key, required this.playlist});

  final PlaylistTile playlist;

  Future<Playlist> getPlaylistInfo() async {
    final response = await http.get(Uri.parse('${SocketService.socket.io.uri}/subsonic?uuid=${SocketService.socket.id}&method=getPlaylist&id=${playlist.id}'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> playlistJson = jsonDecode(response.body)['subsonic-response']['playlist'];
      return Playlist.fromJson(playlistJson);
    }

    throw Exception('Failed to load playlist');
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final playlist = await getPlaylistInfo();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PlaylistInfo(playlist: playlist)),
        );
      },
      child: Container(
        color: Colors.grey, 
        height: 100, 
        width: MediaQuery.of(context).size.width - 20, 
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(playlist.name, style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold, decoration: TextDecoration.none)), 
            Text(playlist.owner, style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.normal, decoration: TextDecoration.none)),
          ],
        ),
      ),
    );
  }
}

class PlaylistTiles {
  static List<PlaylistTile> playlists = [];
  static bool loaded = false;

  static Future<void> getPlaylists() async {
    final response = await http.get(Uri.parse('${SocketService.socket.io.uri}/subsonic?uuid=${SocketService.socket.id}&method=getPlaylists'));
    if (response.statusCode == 200) {
      final List<dynamic> playlistsJson = jsonDecode(response.body)['subsonic-response']['playlists']['playlist'];
      loaded = true;
      playlists = playlistsJson.map((playlistJson) => PlaylistTile.fromJson(playlistJson)).toList();
      return;
    }

    throw Exception('Failed to load playlists');
  }
}

class PlaylistInfo extends StatelessWidget {
  const PlaylistInfo({super.key, required this.playlist});

  final Playlist playlist;

  @override
  Widget build(BuildContext context) {
    return 
      Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          color: const Color.fromARGB(20, 255, 255, 255), 
          width: MediaQuery.of(context).size.width, 
          height: 70, 
          child: Row(
            children: [
              const Padding(padding: EdgeInsets.all(5),),
              IconButton(
                icon: const Icon(Icons.arrow_back),
                color: Colors.white,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const Padding(padding: EdgeInsets.all(5)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(playlist.name, 
                    style: const TextStyle(
                      fontSize: 24, 
                      color: Colors.white,
                      decoration: TextDecoration.none,
                    )
                  ),
                  Text(playlist.owner, 
                    style: const TextStyle(
                      fontSize: 14, 
                      color: Colors.white,
                      decoration: TextDecoration.none,
                    )
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height - 140,
          width: MediaQuery.of(context).size.width,
          child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (final song in playlist.songs) Column(
                        children: [
                          const Padding(padding: EdgeInsets.all(10),),
                          Text(song.title, style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
                        ],
                      ),
                    ],
                  ),
              ),
            ),
        ),
      ],
    );
  }
}