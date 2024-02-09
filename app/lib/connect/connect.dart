import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:convert';

import 'config.dart';
import 'musicPlayer.dart';

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
  bool songPlaying = false;

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
      // socket!.emit('subscribe', 'Master Bedroom speaker');
      socket!.emit('selectChromecast', 'Master Bedroom speaker');
    });

    socket!.onConnectError((data) => showErrorDialog(context, data.toString()));

    socket!.on('subscribe', (data) {

      if ((data['response']['chromecastStatus']['playerState'] == 'PLAYING') != songPlaying) {
        setState(() {
          songPlaying = data['response']['chromecastStatus']['playerState'] == 'PLAYING';
        });
      }

      String id = data['response']['queue']['id'];
      if (id == songId) {
        return;
      }
      socket!.emit('getSongInfo', id);
    });

    socket!.on('playQueue', (data) {
      String id = data['id'];
      
      if (id == songId) {
        return;
      }
      socket!.emit('getSongInfo', id);
    });

    socket!.on('getSongInfo', (data) {
        data = json.decode(data);

        setState(() {
          songTitle = data['response']['title'];
          artist = data['response']['artist'];
          albumArt = data['response']['coverURL'];
        });
      });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(),
      body: MusicPlayer(
        title: songTitle,
        artist: artist,
        albumArt: albumArt,
        isPlaying: songPlaying,
        onPressedPlay: () {
          if (songPlaying) {
            socket!.emit('pause', 'Master Bedroom speaker');
          } else {
            socket!.emit('resume', 'Master Bedroom speaker');
          }
        },
        onPressedSkip: () {
          socket!.emit('skip', 'Master Bedroom speaker');
        },
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