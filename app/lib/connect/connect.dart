import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
  String message = 'temp';
  var songTitle = 'Song Title';
  String artist = 'Artist';
  String albumArt = 'https://via.placeholder.com/150';

  @override
  void initState() {
    super.initState();
    connectToServer();
  }
  void connectToServer() {
    socket = IO.io(Config.BASE_URL, <String, dynamic>{
    "transports": ["websocket"],
});
    // socket!.connect();
    socket!.onConnect((_) {
      print('connect');
      socket!.emit('subscribe', 'Master Bedroom speaker');
    });

    socket!.onConnectError((data) => print(data));

    socket!.on('subscribe', (data) {
      data = json.decode(data);
      String id = data['response']['queue']['id'];
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
      appBar: AppBar(),
      body: MusicPlayer(
        title: songTitle,
        artist: artist,
        albumArt: albumArt,
      ),
    );
  }
}