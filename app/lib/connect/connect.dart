import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'config.dart';
import 'musicPlayer.dart';
import 'playlistSelect.dart';
import 'chromecastSelect.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  IO.Socket? socket;
  String songTitle = 'Song Title';
  String artist = 'Artist';
  String albumArt = 'https://via.placeholder.com/250';
  String songId = '';
  
  String? chromecastName;

  late final AppLifecycleListener _listener;
  late AppLifecycleState? _state;

  @override
  void initState() {
    super.initState();
    _state = SchedulerBinding.instance.lifecycleState;
    connectToServer();

  }

  void connectToServer() {
    socket = IO.io(Config.BASE_URL, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket!.connect();
    socket!.onConnect((_) {
      socket!.emit('getPlaylists');

      _listener = AppLifecycleListener(
        onShow: () {
          if (chromecastName != null){
            socket!.emit('selectChromecast', chromecastName);
          }
        },
        onStateChange: (value) => _state = value,
      );

    });

      socket!.on('selectChromecast', (data) {
        if (data['status'] == 'ok'){
          chromecastName = data['name'];
        }
      });

    socket!.onConnectError(
        (data) => showErrorDialog(context, data.toString(), socket!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MusicPlayer(socket: socket!),
          Positioned(top: 40, right: 0, child: PlaylistSelect(socket: socket!)),
          Positioned(
              bottom: 20, left: 10, child: ChromecastSelect(socket: socket!)),
        ],
      ),
    );
  }
}

void showErrorDialog(BuildContext context, String message, IO.Socket socket) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              socket.connect();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
