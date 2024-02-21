import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:convert';

import 'config.dart';
import 'musicPlayer.dart';
import 'playlistSelect.dart';
import 'chromecastSelect.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  _MusicScreenState createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  IO.Socket? socket; 
  String songTitle = 'Song Title';
  String artist = 'Artist';
  String albumArt = 'https://via.placeholder.com/250';
  String songId = '';

  @override
  void initState() {
    super.initState();
    connectToServer();
  }
  void connectToServer() {
    socket = IO.io(Config.BASE_URL, <String, dynamic>{
    "transports": ["websocket"],
  });
    socket!.onConnect((_) {
      socket!.emit('getPlaylists');
    });

    socket!.onConnectError((data) => showErrorDialog(context, data.toString()));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MusicPlayer(socket: socket!),
          Positioned(top: 40, right: 0, child: playlistSelect(socket: socket!)),
          Positioned(bottom: 0, left: 0, child: ChromecastSelect(socket: socket!)),
        ],
      ),
    );
  }
}

void showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
