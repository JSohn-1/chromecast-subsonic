import 'dart:async';
import 'dart:convert';

import 'package:app/interfaces/song.dart';
import 'package:app/playback_locations_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;

import 'socket_service.dart';

class PlayerContainer {
  static final AudioPlayer player = AudioPlayer(handleInterruptions: false);
  static Stream<Song?> get currentSongStream => _currentSongStreamController.stream;
  static final StreamController<Song?> _currentSongStreamController = StreamController<Song?>.broadcast();

  static List<String> playlist = [];
  static Song? currentSong;
  static int index = -1;
  static bool playing = false;

  static init() async {
    await playQueue();

    SocketService.on('playQueue', (data) async {
      final socket = SocketService.socket;
      final result = await http
          .get(Uri.parse(
              '${socket.io.uri}/subsonic?id=${data[0]['id']}&uuid=${socket.id}&method=getSong'))
          .then((response) {
        final songData = jsonDecode(response.body);
        return Song.fromJson(songData['subsonic-response']['song']);
      });

      PlayerContainer.currentSong = result;
      PlayerContainer.index = data[0]['index'];

      _currentSongStreamController.add(result);
    });

    SocketService.on('changeQueue', (data) async {
      final socket = SocketService.socket;
      final player = PlayerContainer.player;

      final response = await http
          .get(Uri.parse('${socket.io.uri}/queue?uuid=${socket.id}'))
          .then((response) {
        return jsonDecode(response.body);
      });

      PlayerContainer.playlist =
          response['playQueue']['userQueue']['queue'].cast<String>();

      PlayerContainer.index = response['playQueue']['userQueue']['index'];

      final playlist =
          ConcatenatingAudioSource(useLazyPreparation: true, children: [
        for (final song in response['playQueue']['userQueue']['queue'])
          AudioSource.uri(Uri.parse(
              '${SocketService.socket.io.uri}/subsonic/stream?id=$song&uuid=${SocketService.socket.id}')),
      ]);

      if (response['playbackLocation']['uuid'] == socket.id) {
        await player.setAudioSource(playlist,
            initialIndex: PlayerContainer.index);

        player.play();
      }

      playing = response['playbackLocation']['uuid'] == socket.id;
    });

    SocketService.on('setLocation', (data) async {
      final player = PlayerContainer.player;

      if (data[0] == SocketService.socket.id) {
        if (data[1]) {
          final playlist = ConcatenatingAudioSource(children: [
            for (final song in PlayerContainer.playlist) 
              AudioSource.uri(Uri.parse('${SocketService.socket.io.uri}/subsonic/stream?id=$song&uuid=${SocketService.socket.id}'))
          ]);
          await player.setAudioSource(playlist, initialIndex: PlayerContainer.index);
          player.play();

        } else {
          player.pause();
        }
      }

      playing = data[0] == SocketService.socket.id;
    });

    PlayerContainer.player.currentIndexStream.listen((index) async {
      if (index != null) {
        PlayerContainer.index = index;

        final socket = SocketService.socket;

        socket.emit('setIndex', index);

        final song = await http
            .get(Uri.parse(
                '${socket.io.uri}/subsonic?id=${playlist[index]}&uuid=${socket.id}&method=getSong'))
            .then((response) {
          final songData = jsonDecode(response.body);
          return Song.fromJson(songData['subsonic-response']['song']);
        });

        PlayerContainer.currentSong = song;

        _currentSongStreamController.add(song);
      }
    });

    PlayerContainer.player.playingStream.listen((playing) {
      final socket = SocketService.socket;
      socket.emit(playing ? 'resume' : 'pause');
    });

    PlaybackLocationsService.currentMessageStream.listen((event) async {
      if (event == SocketService.socket.id) {
        if (playing) return;

        playing = true;
        final player = PlayerContainer.player;

        final playlist = ConcatenatingAudioSource(children: [
          for (final song in PlayerContainer.playlist) 
            AudioSource.uri(Uri.parse('${SocketService.socket.io.uri}/subsonic/stream?id=$song&uuid=${SocketService.socket.id}'))
        ]);
        player.setAudioSource(playlist, initialIndex: PlayerContainer.index);
      } else {
        player.pause();
        playing = false;
      }
    });
  }

  static Future<void> setSong(String songId) async {
    final socket = SocketService.socket;

    final song = await http
        .get(Uri.parse(
            '${socket.io.uri}/subsonic?id=$songId&uuid=${socket.id}&method=getSong'))
        .then((response) {
      final songData = jsonDecode(response.body);
      return Song.fromJson(songData['subsonic-response']['song']);
    });

    final streamUrl =
        '${socket.io.uri}/subsonic/stream?id=${song.id}&uuid=${socket.id}';

    player.setUrl(streamUrl);
    currentSong = song;

    player.play();

    return;
  }

  static Future<void> playQueue() async {
    final socket = SocketService.socket;

    final response = await http
        .get(Uri.parse('${socket.io.uri}/queue?uuid=${socket.id}'))
        .then((response) {
      return jsonDecode(response.body);
    });

    if (response['playQueue']['userQueue']['index'] == -1) return;

    PlayerContainer.playlist =
        response['playQueue']['userQueue']['queue'].cast<String>();
    PlayerContainer.index = response['playQueue']['userQueue']['index'];
    PlayerContainer.currentSong = await http
        .get(Uri.parse(
            '${socket.io.uri}/subsonic?id=${response['playQueue']['userQueue']['queue'][response['playQueue']['userQueue']['index']]}&uuid=${socket.id}&method=getSong'))
        .then((response) {
      final songData = jsonDecode(response.body);
      return Song.fromJson(songData['subsonic-response']['song']);
    });

    final playlist =
        ConcatenatingAudioSource(useLazyPreparation: true, children: [
      for (final song in response['playQueue']['userQueue']['queue'])
        AudioSource.uri(Uri.parse(
            '${SocketService.socket.io.uri}/subsonic/stream?id=$song&uuid=${SocketService.socket.id}')),
    ]);

    if (response['playbackLocation']['uuid'] == socket.id) {
      await player.setAudioSource(playlist);

      player.play();
    }

    return;
  }

  static Future<void> playPlaylist(String playlistId) async {
    final socket = SocketService.socket;

    socket.emit('playPlaylist', {'id': playlistId});

    final response = await http
        .get(Uri.parse(
            '${socket.io.uri}/subsonic?id=$playlistId&uuid=${socket.id}&method=getPlaylist'))
        .then((response) {
      return jsonDecode(response.body);
    });

    final playlist =
        ConcatenatingAudioSource(useLazyPreparation: true, children: [
      for (final song in response['playlist']['queue'])
        AudioSource.uri(Uri.parse(
            '${SocketService.socket.io.uri}/subsonic/stream?id=$song&uuid=${SocketService.socket.id}')),
    ]);

    await player.setAudioSource(playlist, initialIndex: 0);

    await player.play();

    return;
  }
}
