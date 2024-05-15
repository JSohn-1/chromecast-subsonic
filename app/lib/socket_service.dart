import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';

class SocketService with ChangeNotifier {
  late IO.Socket _socket;
  late String _uuid;

  IO.Socket get socket => _socket;
  String get uuid => _uuid;

  createSocketConnection(String domain) async {
    _socket = IO.io(domain, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket.on('uuid', (_) {
      _uuid = _['uuid'];
    });

    _socket.connect();

    notifyListeners();
  }

  void disposeSocketConnection() {
    if (_socket.connected) _socket.disconnect();
  }
}

class PersistentData {
  static Future<void> login() async {
    final prefs = await SharedPreferences.getInstance();

    final String? domain = prefs.getString('domain');
    final String? username = prefs.getString('username');
    final String? password = prefs.getString('password');

    if (domain != null && username != null && password != null) {
      final socketService = SocketService();
      socketService.createSocketConnection(domain);

      final socket = socketService.socket;

      socket.on('login', (_) {
        
      });

      socket.emit('login', {
        'username': username,
        'password': password,
      });
    }
  }
}