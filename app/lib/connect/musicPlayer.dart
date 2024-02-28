import 'dart:core';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:rxdart/rxdart.dart';

import '../constants.dart';
import '../audio_local.dart';

class MusicPlayer extends StatelessWidget {
  const MusicPlayer({super.key, required this.socket});

  final IO.Socket? socket;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Constants.backgroundColor,
      child: Column(
        children: <Widget>[
          const Spacer(flex: 2),
          ChromecastSelected(socket: socket),
          const Padding(padding: EdgeInsets.all(5)),
          MusicInfo(socket: socket),
          const Padding(
            padding: EdgeInsets.all(5),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            PreviousButton(socket: socket),
            const Padding(
              padding: EdgeInsets.all(5),
            ),
            PlayButton(socket: socket),
            const Padding(
              padding: EdgeInsets.all(5),
            ),
            SkipButton(socket: socket)
          ]),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}

class MusicInfo extends StatefulWidget {
  final IO.Socket? socket;

  const MusicInfo({super.key, required this.socket});

  @override
  State<MusicInfo> createState() => _MusicInfoState();
}

class _MusicInfoState extends State<MusicInfo> {
  IO.Socket? socket;
  MediaItem? mediaItem;

  String songTitle = 'Song Title';
  String artist = 'Artist';
  String albumArt = 'https://via.placeholder.com/350';
  String songId = '';

  @override
  void initState() {
    super.initState();
    socket = widget.socket;

    socket!.on('playQueue', (data) {
      if (data['response']['index'] == -1) {
        setState(() {
          songTitle = 'Song Title';
          artist = 'Artist';
          albumArt = 'https://via.placeholder.com/350';
          songId = '';
        });

        return;
      }
      final String id = data['response']['id'];

      if (id == songId) {
        return;
      }
      socket!.emit('getSongInfo', id);
    });

    socket!.on('getCurrentSong', (data) {
      final String id = data['response']['id'];
      socket!.emit('getSongInfo', id);
    });

    socket!.on('getSongInfo', (data) {
      setState(() {
        songTitle = data['response']['title'];
        artist = data['response']['artist'];
        albumArt = data['response']['coverURL'];
        mediaItem = MediaItem(
            id: songId,
            title: songTitle,
            artist: artist,
            album: albumArt,
            duration: Duration(seconds: data['response']['duration']));
      });
    });

    socket!.on('selectChromecast', (data) {
      socket!.emit('getCurrentSong');
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(albumArt, width: 350, height: 350),
          ),
          const Padding(padding: EdgeInsets.all(10)),
          Text(songTitle,
              style: const TextStyle(
                  color: Constants.primaryTextColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const Padding(padding: EdgeInsets.all(2)),
          Text(artist,
              style: const TextStyle(
                  color: Constants.secondaryTextColor, fontSize: 14)),
          const Padding(
            padding: EdgeInsets.all(5),
          ),
        ],
      ),
    );
  }
}

class PlayButton extends StatefulWidget {
  const PlayButton({super.key, required this.socket});

  final IO.Socket? socket;

  @override
  State<PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<PlayButton> {
  IO.Socket? socket;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    socket = widget.socket;

    socket!.on('subscribe', (data) {
      data = data['response']['chromecastStatus'];
      if ((data['playerState'] == 'PLAYING') != isPlaying) {
        setState(() {
          isPlaying = data['playerState'] == 'PLAYING';
        });
      }
    });

    socket!.on('getStatus', (data) {
      if (data['status'] == 'error') {
        isPlaying = false;
        return;
      }

      if ((data['response']['playerState'] == 'PLAYING') != isPlaying) {
        setState(() {
          isPlaying = data['response']['playerState'] == 'PLAYING';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 75,
      height: 75,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Constants.secondaryColor,
      ),
      child: IconButton(
        icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
            color: Constants.backgroundColor, size: 50),
        onPressed: () {
          if (isPlaying) {
            socket!.emit('pause');
          } else {
            socket!.emit('resume');
          }
        },
      ),
    );
  }
}

class SkipButton extends StatelessWidget {
  const SkipButton({super.key, required this.socket});

  final IO.Socket? socket;

  void onPressed() {
    socket!.emit('skip');
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.skip_next,
          color: Constants.secondaryColor, size: 50),
      onPressed: onPressed,
    );
  }
}

class PreviousButton extends StatelessWidget {
  const PreviousButton({super.key, required this.socket});

  final IO.Socket? socket;

  void onPressed() {
    socket!.emit('previous');
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.skip_previous,
          color: Constants.secondaryColor, size: 50),
      onPressed: onPressed,
    );
  }
}

class ChromecastSelected extends StatefulWidget {
  const ChromecastSelected({super.key, required this.socket});

  final IO.Socket? socket;

  @override
  State<ChromecastSelected> createState() => _ChromecastSelectedState();
}

class _ChromecastSelectedState extends State<ChromecastSelected> {
  IO.Socket? socket;
  String chromecastSelected = '_';

  @override
  void initState() {
    super.initState();
    socket = widget.socket;

    socket!.on('selectChromecast', (data) {
      setState(() {
        chromecastSelected = data['response'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(chromecastSelected,
        style:
            const TextStyle(color: Constants.primaryTextColor, fontSize: 18));
  }
}

class SeekBar extends StatefulWidget {
  const SeekBar({super.key, required this.socket});

  final IO.Socket? socket;

  @override
  State<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  IO.Socket? socket;
  double position = 0;
  double max = 100;

  @override
  void initState() {
    super.initState();
    socket = widget.socket;

    socket!.on('subscribe', (data) {
      data = data['response']['chromecastStatus'];
      if (data['playerState'] == 'PLAYING') {
        setState(() {
          position = data['currentTime'] / data['mediaInfo']['duration'];
          max = data['mediaInfo']['duration'];
        });
      }
    });

    socket!.on('getStatus', (data) {
      if (data['status'] == 'error') {
        return;
      }

      if (data['response']['playerState'] == 'PLAYING') {
        setState(() {
          position =
              data['response']['currentTime'] / data['response']['duration'];
          max = data['response']['duration'];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: position,
      max: max,
      onChanged: (double newValue) {
        setState(() {
          position = newValue;
          socket!.emit('seek', newValue);
        });
      },
      onChangeEnd: (double newValue) {
        socket!.emit('seek', newValue);
      },
    );
  }
}
