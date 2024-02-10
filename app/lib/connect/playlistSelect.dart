import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../constants.dart';

class playlistSelect extends StatefulWidget {
  final IO.Socket? socket;
  playlistSelect({super.key, required this.socket});

  @override
  _playlistSelectState createState() => _playlistSelectState();
}

class _playlistSelectState extends State<playlistSelect> {
  IO.Socket? socket; 
  List<dynamic> playlists = [];

  @override
  void initState() {
    super.initState();
    socket = widget.socket;

    socket!.emit('getPlaylists');

    socket!.on('getPlaylists', (data) {
      setState(() {
        playlists = data['response'];
      });
    });
  }

  void refreshPlaylists() {
    socket!.emit('getPlaylists');
  }

  void selectPlaylist(String id) {
    socket!.emit('queuePlaylist', id);
  }

  @override
  Widget build(BuildContext context) {
    return PlaylistOpener(playlists: playlists,);
  }
}

class PlaylistOpener extends StatelessWidget {
  PlaylistOpener({super.key, required this.playlists});
  
  List<dynamic> playlists = [];
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Constants.primaryColor,
      ),
      child: IconButton(
        iconSize: 50,
        icon: const Icon(Icons.list, color: Constants.backgroundColor, size: 30),
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    const Text('Select a playlist'),
                    for (var playlist in playlists) 
                      PlaylistItem(
                        name: playlist['name'],
                        coverURL: "https://via.placeholder.com/50/", //"playlist['coverURL']" 
                        onPressed: () {
                          print('pressed ${playlist['name']}');
                          // selectPlaylist(playlists[playlist]['id']);
                          // Navigator.pop(context);
                        },
                      ),
                  ],
                ),
              );
            },
          );
        }
      ),
    );
  }
}

class PlaylistItem extends StatelessWidget {
  const PlaylistItem({super.key, required this.name, required this.coverURL, required this.onPressed});
  final String name;
  final String coverURL;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 100,
      color: Constants.backgroundColor,
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(coverURL),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            width: 100,
            height: 100,
            child: Column(
              children: [
                Text(name, style: TextStyle(color: Constants.primaryTextColor)),
                ElevatedButton(
                  onPressed: onPressed,
                  child: const Text('Select'),
                ),
              ],
            ),
          ),
        ],
      )
    );
  }
}

// https://api.flutter.dev/flutter/material/showModalBottomSheet.html