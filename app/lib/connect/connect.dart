import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'config.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  _MusicScreenState createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  IO.Socket? socket; 
  String message = 'temp';

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
      socket!.emit('subscribe', 'Master Bedroom speaker');
    });

    socket!.on('subscribe', (data) {
      setState(() {
        message = data;
      });
      });

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Socket.IO Chat'),
      ),
      body: Text(message),
    );
  }
}