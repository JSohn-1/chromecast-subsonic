import 'dart:convert';
import 'dart:ffi';
import 'dart:ui';

import 'package:app/interfaces/playlist.dart';
import 'package:app/interfaces/song.dart';
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
    return InkWell(
      onTap: () async {
        final playlist = await getPlaylistInfo();
        Navigator.push(
          context,
          PageRouteBuilder(opaque: false, pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
            return PlaylistInfo(playlist: playlist);
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 100),
          reverseTransitionDuration: const Duration(milliseconds: 100),
          ),
          
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color.fromARGB(16, 255, 255, 255), 
        ),
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
      Align(
        alignment: Alignment.topCenter,
        child: Container(
          color: const Color.fromARGB(255, 18, 18, 18),
          height: MediaQuery.of(context).size.height- 70,
          child: Column(
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
                    const Padding(padding: EdgeInsets.all(5)),
                    Container(
                      alignment: Alignment.centerRight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color.fromARGB(20, 255, 255, 255),
                      ),
                      padding: const EdgeInsets.all(5),
                      height: 30,
                      child: Text('${playlist.songs.length} songs', 
                        style: const TextStyle(
                          fontSize: 14, 
                          color: Colors.white,
                          decoration: TextDecoration.none,
                        )
                      ),
                    )
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
                                const Padding(padding: EdgeInsets.all(5),),
                                SongItem(song: song,)
                              ],
                            ),
                          ],
                        ),
                    ),
                  ),
              ),
            ],
                ),
        ),
      );
  }
}

class SongItem extends StatelessWidget {
  const SongItem({super.key, required this.song});

  final Song song;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color.fromARGB(16, 255, 255, 255), 
      ),
      height: 50, 
      width: MediaQuery.of(context).size.width - 20, 
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: NetworkImage('${SocketService.socket.io.uri}/subsonic/cover?uuid=${SocketService.socket.id}&size=50&id=${song.id}'),
                fit: BoxFit.scaleDown,
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.all(2)),
          SizedBox(
            width: MediaQuery.of(context).size.width - 140,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(song.title, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold, decoration: TextDecoration.none, overflow: TextOverflow.ellipsis)), 
                Text(song.artist, style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.normal, decoration: TextDecoration.none, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
