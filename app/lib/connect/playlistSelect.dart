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
  Map<String, dynamic> playlists = {};

  @override
  void initState() {
    super.initState();
    socket = widget.socket;

    socket!.emit('getPlaylists');

    socket!.on('getPlaylists', (data) {
      setState(() {
        playlists = data;
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
    return const PlaylistOpener();
  }
}

class PlaylistOpener extends StatelessWidget {
  const PlaylistOpener({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Constants.secondaryColor,
      ),
      child: IconButton(
        iconSize: 50,
        icon: const Icon(Icons.list, color: Constants.backgroundColor, size: 30),
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context) {
              return Container();
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
      width: context.size!.width - 20,
      height: 100,
      child: Row(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(coverURL),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            width: context.size!.width - 120,
            height: 100,
            child: Column(
              children: [
                Text(name),
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