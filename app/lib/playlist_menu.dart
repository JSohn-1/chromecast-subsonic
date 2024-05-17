import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:app/interfaces/playlist_tile.dart';
import 'socket_service.dart';

class PlaylistMenu extends StatefulWidget {
  const PlaylistMenu({super.key, List<PlaylistTile> playlists = const []});

  @override
  State<PlaylistMenu> createState() => _PlaylistMenuState();
}

class _PlaylistMenuState extends State<PlaylistMenu> {
  List<PlaylistTile> playlists = [];
  
    @override
    void initState() {
      super.initState();
      _loadPlaylists();
    }

    Future<void> _loadPlaylists() async {
      final response = await http.get(Uri.parse('${SocketService.socket.io.uri}/subsonic?uuid=${SocketService.socket.id}&method=getPlaylists'));
      if (response.statusCode == 200) {
        final List<dynamic> playlistsJson = jsonDecode(response.body)['subsonic-response']['playlists']['playlist'];
        setState(() {
          playlists = playlistsJson.map((playlistJson) => PlaylistTile.fromJson(playlistJson)).toList();
        });
      }
    }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(padding: EdgeInsets.only(top: 70)),
            SizedBox(
              height: MediaQuery.of(context).size.height - 70,
              width: MediaQuery.of(context).size.width,
              child: RefreshIndicator(
                onRefresh: _loadPlaylists,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (final playlist in playlists) Column(
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
        ),
        Positioned(
          top: 0, 
          child: Container(
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
          )
        ),
      ],
    );
  }
}

class PlaylistItem extends StatelessWidget {
  const PlaylistItem({super.key, required this.playlist});

  final PlaylistTile playlist;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey, 
      height: 100, 
      width: MediaQuery.of(context).size.width - 20, 
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Text(playlist.name, style: const TextStyle(fontSize: 20)), 
          Text(playlist.owner, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

