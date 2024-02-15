import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:convert';

import 'config.dart';
import 'musicPlayer.dart';
import 'playlistSelect.dart';

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
      socket!.emit('selectChromecast', 'Master Bedroom speaker');
      socket!.emit('getCurrentSong');
      socket!.emit('getStatus');
      socket!.emit('getPlaylists');
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

    socket!.on('getCurrentSong', (data) {
      String id = data['response']['id'];
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

    socket!.on('getStatus', (data) {
      if (data['status'] == 'error') {
        return;
      }

      setState(() {
        songPlaying = data['response']['playerState'] == 'PLAYING';
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MusicPlayer(
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
          Positioned(top: 0, right: 0, child: playlistSelect(socket: socket!)),
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
