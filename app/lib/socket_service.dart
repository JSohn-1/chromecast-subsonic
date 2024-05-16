import 'dart:async';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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

    _socket.connect();

    _socket.onConnect((_) {
      notifyListeners();
    });

    notifyListeners();
  }

  void disposeSocketConnection() {
    if (_socket.connected) _socket.disconnect();
  }
}

class PersistentData {
  static Future<bool> login() async {
    final prefs = await SharedPreferences.getInstance();

    final String? domain = prefs.getString('domain');
    final String? username = prefs.getString('username');
    final String? password = prefs.getString('password');

    if (domain != null && username != null && password != null) {
      final socketService = SocketService();
      socketService.createSocketConnection(domain);

      final socket = socketService.socket;

      final Completer<int> completer = Completer<int>();

      socket.onConnect((_) async {
        completer.complete(0);
        socket.off('connect');
      });

      socket.onConnectError((_) {
        socketService.disposeSocketConnection();
      });

      final result = await Future.any([completer.future, Future.delayed(const Duration(seconds: 5), () => 1)]);

      if (result == 1) {
        socketService.disposeSocketConnection();
        return false;
      }

      final res = await http.post(
        Uri.parse('$domain/subsonic/login?&uuid=${socket.id}&username=$username&password=$password'),
      );

      if (res.statusCode == 200) {
        return true;
      } else {

        socketService.disposeSocketConnection();
        return false;
      }
    }
    return false;
  }

  static Future<void> saveLogin(String domain, String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('domain', domain);
    await prefs.setString('username', username);
    await prefs.setString('password', password);
  }
}