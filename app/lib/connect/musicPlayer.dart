import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../constants.dart';

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
          SeekBar(socket: socket),
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

    socket!.on('getStatus', (data) {
      if (data['status'] == 'error') {
        isPlaying = false;
        return;
      }
      if ((data['response']['chromecastStatus']['playerState'] == 'PLAYING') != 
        isPlaying) {
        setState(() {
          isPlaying = 
            data['response']['chromecastStatus']['playerState'] == 'PLAYING';
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
  
  late StreamController<Map<String, Duration>> positionstream;

  bool isUserDragging = false;
  double changingSlider = 0;

  @override
  void initState() {
    super.initState();
    socket = widget.socket;
    positionstream = createPositionStream;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: positionstream.stream,
        builder: (context, snapshot) {
          Duration position = snapshot.data?['position'] ?? Duration.zero;
          Duration mediaLength = snapshot.data?['mediaLength'] ?? Duration.zero;



          if (!snapshot.hasData || isUserDragging) {
            return SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Slider(
                activeColor: Constants.primaryColor, 
                value: changingSlider, 
                max: mediaLength.inMilliseconds.toDouble(), 
                onChanged: (_) {
                  changingSlider = _;
                  setState(() {});
                },
                onChangeEnd: (_) {                
                  isUserDragging = false;
                  socket!.emit('seek', _ ~/ 1000);
                  positionstream.add({
                    'position': Duration(milliseconds: _.toInt()), 
                    'mediaLength': mediaLength
                  });
                },
              ),
            );
          }

          if (position > mediaLength) {
            position = mediaLength;
          }

          return SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Slider(
              activeColor: Constants.primaryColor,
              value: position.inMilliseconds.toDouble(),
              max: mediaLength.inMilliseconds.toDouble(),
              onChanged: (value) {
                isUserDragging = true;
                changingSlider = value;
                positionstream.add({
                  'position': Duration(milliseconds: value.toInt()), 
                  'mediaLength': mediaLength
                });
              },
            ),
          );
        });
  }

  StreamController<Map<String, Duration>> get createPositionStream {
    final StreamController<Map<String, Duration>> controller =
        StreamController<Map<String, Duration>>();
    Duration position = Duration.zero;
    Duration mediaLength = Duration.zero;
    bool isPlaying = false;

    socket!.on('getSongInfo', (song) {
      position = Duration.zero;
      mediaLength = Duration(seconds: song['response']['duration'].toInt());
      isPlaying = false;

      socket!.emit('getStatus');

      controller.add({'position': position, 'mediaLength': mediaLength});
    });

    socket!.on('getStatus', (data) {
      if (data['status'] == 'error') {
        return;
      }
      isPlaying = 
        data['response']['chromecastStatus']['playerState'] == 'PLAYING';

      if (isPlaying) {
        position = Duration(
            milliseconds: 
              (data['response']['chromecastStatus']['currentTime'] * 1000)
              .toInt());

        controller.add({'position': position, 'mediaLength': mediaLength});
      }
    });

    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (isPlaying &&
          position + const Duration(milliseconds: 100) < mediaLength) {
        position += const Duration(milliseconds: 100);
        controller.add({'position': position, 'mediaLength': mediaLength});
      }
    });

    return controller;
  }
}
