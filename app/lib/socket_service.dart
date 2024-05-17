import 'dart:async';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SocketService {
  static late IO.Socket _socket;

  static IO.Socket get socket => _socket;

  static Future<bool> createSocketConnection(String domain) async {
    _socket = IO.io(domain, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    final Completer<int> completer = Completer<int>();

    _socket.onConnect((_) {
      completer.complete(0);
    });

    _socket.onConnectError((_) {
      completer.complete(1);
    });

    _socket.connect();

    final result = await Future.any([completer.future, Future.delayed(const Duration(seconds: 5), () => 1)]);

    if (result == 1) {
      disposeSocketConnection();
      return false;
    }

    return true;

  }

  static void disposeSocketConnection() {
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
      SocketService.createSocketConnection(domain);

      final socket = SocketService.socket;

      final Completer<int> completer = Completer<int>();

      socket.onConnect((_) async {
        completer.complete(0);
        socket.off('connect');
      });

      socket.onConnectError((_) {
        SocketService.disposeSocketConnection();
      });

      final result = await Future.any([completer.future, Future.delayed(const Duration(seconds: 5), () => 1)]);

      if (result == 1) {
        print('Failed to connect to server');
        SocketService.disposeSocketConnection();
        return false;
      }

      final res = await http.post(
        Uri.parse('$domain/subsonic/login?&uuid=${socket.id}&username=$username&password=$password'),
      );

      if (res.statusCode == 200) {
        // print(socketService.socket.id);
        return true;
      } else {

        SocketService.disposeSocketConnection();
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