import 'dart:async';
// import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';

import 'socket_service.dart';

class Player extends StatelessWidget {
  const Player({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final player = AudioPlayer();

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
            SongSelectButton(player: player, getStreamUrl: getStreamUrl),
            PlayButton(player: player),
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

  const PlayButton({Key? key, required this.player}) : super(key: key);

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