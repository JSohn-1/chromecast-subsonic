import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService with ChangeNotifier {
  late IO.Socket _socket;
  late String _uuid;

  IO.Socket get socket => _socket;
  String get uuid => _uuid;

  createSocketConnection(String domain) {
    _socket = IO.io(domain, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    _socket.connect();

    _socket.on('uuid', (_) {
      _uuid = _['uuid'];
    });

    notifyListeners();
  }

  void disposeSocketConnection() {
    if (_socket.connected) _socket.disconnect();
  }
}