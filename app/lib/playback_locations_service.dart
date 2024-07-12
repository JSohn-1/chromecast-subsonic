import 'dart:convert';
import 'dart:async';

import 'package:app/interfaces/playback_location.dart';
import 'package:http/http.dart' as http;

import 'package:app/socket_service.dart';

class PlaybackLocationsService {
  static List<PlaybackLocation> playbackLocations = [];
  static PlaybackLocation? currentLocation;
  static final StreamController<String> _availMessageStreamController =
      StreamController<String>.broadcast();
  static final StreamController<String> _currentMessageStreamController =
      StreamController<String>.broadcast();

  static Stream<String> get messageStream => _availMessageStreamController.stream;
  static Stream<String> get currentMessageStream => _currentMessageStreamController.stream;

  static void sendMessage(String message) {
    _availMessageStreamController.add(message);
  }

  static void dispose() {
    _availMessageStreamController.close();
  }

  static void sendCurrentMessage(String message) {
    _currentMessageStreamController.add(message);
  }

  static void disposeCurrent() {
    _currentMessageStreamController.close();
  }

  static Future<void> init() async {
    http
        .get(Uri.parse(
            '${SocketService.socket.io.uri}/getLocations?uuid=${SocketService.socket.id}&exclude=${SocketService.socket.id}'))
        .then((response) {
      final data = jsonDecode(response.body)['locations'];
      for (final location in data) {
        playbackLocations.add(PlaybackLocation.fromJson(location));
      }
      sendMessage('update');
    });

    http.get(Uri.parse('${SocketService.socket.io.uri}/currentLocation?uuid=${SocketService.socket.id}&exclude=${SocketService.socket.id}'))
        .then((response) {
      print('rec: ' + response.body);

      final data = jsonDecode(response.body);
      currentLocation = PlaybackLocation.fromJson(data);
      print(currentLocation!.name);
      sendCurrentMessage(currentLocation!.name);
    });

    // Get playback locations
    SocketService.on('newLocation', (data) {
      print('data: $data');
      playbackLocations.add(PlaybackLocation(id: data[0], name: data[1]));
      sendMessage('update');
    });

    SocketService.on('removeLocation', (data) {
      playbackLocations.removeWhere((element) => element.id == data[0]);
      sendMessage('update');
    });

    SocketService.on('updateLocation', (data) {
      if (data[0] == ''){
        currentLocation = null;
        sendCurrentMessage('Not Playing');
        return;
      }

      currentLocation = PlaybackLocation(id: data[0], name: data[1]);
      sendCurrentMessage(data[0]);
    });
  }

  static Future<void> getPlaybackLocations() async {
    await http.post(Uri.parse(SocketService.socket.io.uri)).then((response) {
      final data = jsonDecode(response.body);
      playbackLocations = data['playbackLocations'];
      sendMessage('update');
    });
  }

  static Future<Map> setPlaybackLocation(String id) async {
    final res = await http.post(Uri.parse(SocketService.socket.io.uri)).then((response) {
      final data = jsonDecode(response.body);
      return {'message': data['message'], 'status': data['status']};
    });
    return res;
  }
}
