import 'dart:async';
import 'dart:io';

import 'package:app/player.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';

class SocketService {
  static late IO.Socket _socket;
  static final StreamController<dynamic> _socketResponseController = StreamController<dynamic>.broadcast();
  static final Map<String, List<Function(dynamic)>> _eventHandlers = {};

  static Stream<dynamic> get socketResponses => _socketResponseController.stream;
  static IO.Socket get socket => _socket;

  static Future<bool> createSocketConnection(String domain) async {
    print('creating socket connection');
    _socket = IO.io(domain, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    final Completer<int> completer = Completer<int>();

    _socket.onConnect((_) {
      completer.complete(0);
    });

    _socket.onConnectError((_) {
      print('error: $_');
      completer.complete(1);
    });

    _socket.onAny((event, data) {
      // for (final handler in _eventHandlers.entries) {
      //   print(handler.key);
      // }

      // print('event $event');
      if (_eventHandlers.containsKey(event)) {
        // print(data);
        // _eventHandlers[event]!(data);
        for (final handler in _eventHandlers[event]!) {
          handler(data);
        }
      }
    });

    _socket.connect();

    final result = await Future.any([completer.future/*, Future.delayed(const Duration(seconds: 5), () {print('timed out'); return 1;})*/]);

    if (result == 1) {
      disposeSocketConnection();
      return false;
    }

    return true;

  }

  static void on(String eventName, Function(dynamic) handler) {
    if (!_eventHandlers.containsKey(eventName)) {
      _eventHandlers[eventName] = [];
    }

    _eventHandlers[eventName]!.add(handler);
  }

  static void disposeSocketConnection() {
    if (_socket.connected) _socket.disconnect();
  }
}

class PersistentData {
  static Future<String> getDeviceName() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.model;
    } else if (Platform.isIOS) {
      final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.name;
    } else if (Platform.isMacOS) {
      final MacOsDeviceInfo macInfo = await deviceInfo.macOsInfo;
      return macInfo.computerName;
    } else if (Platform.isWindows) {
      final WindowsDeviceInfo windowsInfo = await deviceInfo.windowsInfo;
      return windowsInfo.computerName;
    } else if (Platform.isLinux) {
      final LinuxDeviceInfo linuxInfo = await deviceInfo.linuxInfo;
      return linuxInfo.prettyName;
    }
    return 'Unknown';
  }

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
        print('1error: $_');
        SocketService.disposeSocketConnection();
      });

      final result = await Future.any([completer.future/*, Future.delayed(const Duration(seconds: 5), () => 1)*/]);

      if (result == 1) {
        print('Failed to connect to server');
        SocketService.disposeSocketConnection();
        return false;
      }

      final name = await getDeviceName();

      print('name: $name');

      final res = await http.post(
        Uri.parse('$domain/subsonic/login?&uuid=${socket.id}&name=$name&username=$username&password=$password'),
      );

      if (res.statusCode == 200) {
        // print(socketService.socket.id);
        await PlayerContainer.init();

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
