import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;

import 'package:app/socket_service.dart';

class PlaybackLocationsService {
  static List<Map<String, String>> playbackLocations = [];
  static StreamController<String> _messageStreamController = StreamController<String>.broadcast();

  static Stream<String> get messageStream => _messageStreamController.stream;

  static void sendMessage(String message) {
    _messageStreamController.add(message);
  }

  static void dispose() {
    _messageStreamController.close();
  }

  static Future<void> init() async {
    // Get playback locations
    SocketService.on('newLocation', (data) {
      playbackLocations.add({'id': data[0], 'name': data[1]});
      sendMessage('update');
    });

    SocketService.on('removeLocation', (data) {
      playbackLocations.removeWhere((element) => element['id'] == data[0]);
      sendMessage('update');
    });
  }

  Future<void> getPlaybackLocations() async {
    await http
      .post(Uri.parse(SocketService.socket.io.uri))
      .then((response) {
        final data = jsonDecode(response.body);
        playbackLocations = data['playbackLocations'];
        sendMessage('update');
      });
  }
}
