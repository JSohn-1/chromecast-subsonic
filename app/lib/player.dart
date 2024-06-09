import 'dart:async';
import 'dart:collection';
import 'dart:convert';
// import 'dart:ffi';

import 'package:app/interfaces/song.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;

import 'socket_service.dart';

class PlayerContainer {
  static final AudioPlayer player = AudioPlayer();
  static ConcatenatingAudioSource? playlist;
  static Song? currentSong;

  static init() async {
    await playQueue();

    print('queued');

    SocketService.on('playQueue', (data) {
      setSong(data['id']);
    });

    SocketService.on('changeQueue', (data) async {
      final socket = SocketService.socket;

      final response = await http.get(Uri.parse('${socket.io.uri}/queue?uuid=${socket.id}')).then((response) {
        return jsonDecode(response.body);
      });

      if(response['playQueue']['userQueue']['queue'].isEmpty) return;

      PlayerContainer.playlist = ConcatenatingAudioSource(useLazyPreparation: true, children: [
        for (final song in response['userQueue']['queue'])
          AudioSource.uri(Uri.parse('${SocketService.socket.io.uri}/subsonic/stream?id=$song&uuid=${SocketService.socket.id}')),
      ]);

      if(response['playbackLocation']['uuid'] == socket.id) {
        await player.setAudioSource(PlayerContainer.playlist!);

        player.play();
      }

      // await player.setAudioSource(playlist);

      return; 
    });
  }

  static Future<void> setSong(String songId) async {
    final socket = SocketService.socket;

    final song = await http.get(Uri.parse('${socket.io.uri}/subsonic?id=$songId&uuid=${socket.id}&method=getSong')).then((response) {
      final songData = jsonDecode(response.body);
      return Song.fromJson(songData['subsonic-response']['song']);
    });

    final streamUrl = '${socket.io.uri}/subsonic/stream?id=${song.id}&uuid=${socket.id}';

    print(streamUrl);

    player.setUrl(streamUrl);
    currentSong = song;

    player.play();

    return;
  }

  static Future<void> playQueue() async {
    final socket = SocketService.socket;

    final response = await http.get(Uri.parse('${socket.io.uri}/queue?uuid=${socket.id}')).then((response) {
      return jsonDecode(response.body);
    });

    if(response['playQueue']['userQueue']['queue'].isEmpty) return;

    PlayerContainer.playlist = ConcatenatingAudioSource(useLazyPreparation: true, children: [
      for (final song in response['userQueue']['queue'])
        AudioSource.uri(Uri.parse('${SocketService.socket.io.uri}/subsonic/stream?id=$song&uuid=${SocketService.socket.id}')),
    ]);

    if(response['playbackLocation']['uuid'] == socket.id) {
      await player.setAudioSource(PlayerContainer.playlist!);

      player.play();
    }

    // await player.setAudioSource(playlist);

    return;
  }

  static Future<void> playPlaylist(String playlistId) async {
    final socket = SocketService.socket;

    socket.emit('playPlaylist', {'id': playlistId});

    final response = await http.get(Uri.parse('${socket.io.uri}/subsonic?id=$playlistId&uuid=${socket.id}&method=getPlaylist')).then((response) {
      return jsonDecode(response.body);
    });

    print('${socket.io.uri}/subsonic?id=$playlistId&uuid=${socket.id}&method=getPlaylist');

    PlayerContainer.playlist = ConcatenatingAudioSource(useLazyPreparation: true, children: [
      for (final song in response['playlist']['queue'])
        AudioSource.uri(Uri.parse('${SocketService.socket.io.uri}/subsonic/stream?id=$song&uuid=${SocketService.socket.id}')),
    ]);

    await player.setAudioSource(PlayerContainer.playlist!, initialIndex: 0);

    player.play();

    return;
  }
}

class Player extends StatelessWidget {
  const Player({super.key});

  @override
  Widget build(BuildContext context) {
    String getStreamUrl(String id) {
      final socket = SocketService.socket;

      return '${socket.io.uri}/subsonic/stream?id=$id&uuid=${socket.id}';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Player'),
      ),
      body: Center(
        child: Column(
          children: [
            SongSelectButton(player: PlayerContainer.player, getStreamUrl: getStreamUrl),
            PlayButton(player: PlayerContainer.player),
          ],
        ),
      ),
    );
  }
}

class SongSelectButton extends StatelessWidget {
  const SongSelectButton({
    super.key,
    required this.player,
    required this.getStreamUrl,
  });

  final AudioPlayer player;
  final String Function(String) getStreamUrl;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Enter Song ID'),
              content: TextField(
                onChanged: (value) {
                  // Store the entered song ID
                  String songId = value;
                  Navigator.pop(context, songId);
                },
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    // Use a default song ID if none is entered
                    String songId = 'default_song_id';
                    Navigator.pop(context, songId);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        ).then((songId) async {
          // Use the entered song ID to create the music player
          if (songId != null) {
            String streamUrl = getStreamUrl(songId);
            // Create the music player using the stream URL
            // TODO: Implement the music player
            await player.setUrl(streamUrl);
            player.play();
          }
        });
      },
      child: Text('Select Song'),
    );
  }
}

class PlayButton extends StatefulWidget {
  final AudioPlayer player;

  const PlayButton({super.key, required this.player});

  @override
  _PlayButtonState createState() => _PlayButtonState();
}

class _PlayButtonState extends State<PlayButton> {
  bool playing = false;

  StreamSubscription<bool>? _playbackSubscription;

    @override
    void initState() {
      super.initState();
      _playbackSubscription = widget.player.playingStream.listen((event) {
        setState(() {
          playing = event;
        });
      });
    }

    @override
    void dispose() {
      _playbackSubscription?.cancel();
      super.dispose();
    }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (playing) {
          widget.player.pause();
        } else {
          widget.player.play();
        }
      },
      child: Text(playing ? 'Pause' : 'Play'),
    );
  }
}

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key});

  @override
  _MiniPlayerState createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {

  StreamSubscription<bool>? _playbackSubscription;

    @override
    void initState() {
      super.initState();
      _playbackSubscription = PlayerContainer.player.playingStream.listen((event) {
        setState(() {});
      });
    }

    @override
    void dispose() {
      _playbackSubscription?.cancel();
      super.dispose();
    }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      width: MediaQuery.of(context).size.width - 10,
      height: 70,
      child: Row(
        children: [
          Image.network(
           '${SocketService. socket.io.uri}/subsonic/cover?id=${PlayerContainer.currentSong?.id}&uuid=${SocketService.socket.id}',
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
          const Padding(padding: EdgeInsets.all(8)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text(PlayerContainer.currentSong?.title ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text(PlayerContainer.currentSong?.artist ?? '', style: const TextStyle(color: Colors.grey)),
          ],),
          MiniPlayButton(player: PlayerContainer.player),
        ],
      ),
    );
  }
}

class MiniPlayButton extends StatefulWidget {
  final AudioPlayer player;

  const MiniPlayButton({super.key, required this.player});

  @override
  _MiniPlayButtonState createState() => _MiniPlayButtonState();
}

class _MiniPlayButtonState extends State<MiniPlayButton> {
  bool playing = false;

  StreamSubscription<bool>? _playbackSubscription;

    @override
    void initState() {
      super.initState();
      _playbackSubscription = widget.player.playingStream.listen((event) {
        setState(() {
          playing = event;
        });
      });
    }

    @override
    void dispose() {
      _playbackSubscription?.cancel();
      super.dispose();
    }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (playing) {
          widget.player.pause();
        } else {
          widget.player.play();
        }
      },
      child: Text(playing ? 'Pause' : 'Play'),
    );
  }
}