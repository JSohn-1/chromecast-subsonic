// Create the music screen which will take in the parameters of the song title, artist, and album art. 
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../constants.dart';

class MusicPlayer extends StatelessWidget {
  const MusicPlayer({super.key, required this.title, required this.artist, required this.albumArt, required this.onPressedSkip, required this.socket});

  final IO.Socket? socket;

  final String title;
  final String artist;
  final String albumArt;

  final VoidCallback onPressedSkip;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Constants.backgroundColor,
      width: double.infinity,
      height: double.infinity,
      child: Column(
          children: <Widget>[
            const Spacer( flex: 2),
            ChromecastSelected(socket: socket),
            const Padding(padding: EdgeInsets.all(5)),
            Image.network(albumArt, width: 350, height: 350),
            const Padding(padding: EdgeInsets.all(15)),
            Text(title, style: const TextStyle(color: Constants.primaryTextColor, fontSize: 15)),
            const Padding(padding: EdgeInsets.all(2)),
            Text(artist, style: const TextStyle(color: Constants.secondaryTextColor, fontSize: 12)),
            const Padding(padding: EdgeInsets.all(5),),
            Row(
              mainAxisAlignment: MainAxisAlignment.center, 
              children: [
                PreviousButton(onPressed: () {}),
                const Padding(padding: EdgeInsets.all(5),),
                PlayButton(socket: socket),
                const Padding(padding: EdgeInsets.all(5),),
                SkipButton(onPressed: onPressedSkip)
                ]),
            const Spacer( flex: 3),
          ],
        ),
    );
  }
}

class MusicInfo extends StatefulWidget {
   final IO.Socket? socket;

  const MusicInfo({super.key, required this.socket});

  @override
  _MusicInfoState createState() => _MusicInfoState();


}

class _MusicInfoState extends State<MusicInfo> {
  IO.Socket? socket;
  String songTitle = '';
  String artist = '';
  String albumArt = '';

  @override
  void initState() {
    super.initState();

    socket!.on('playQueue', (data) {
      print(data);
      setState(() {
        songTitle = data['response']['title'];
        artist = data['response']['artist'];
        albumArt = data['response']['albumArt'];
      });
    });

    socket!.on('selectChromecast', (data) {
      print('selectChromecast');
      socket!.emit('getCurrentSong');
    });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Constants.backgroundColor,
      width: double.infinity,
      height: double.infinity,
      child: Column(
          children: <Widget>[
            const Spacer( flex: 2),
            Image.network(albumArt, width: 250, height: 250),
            const Padding(padding: EdgeInsets.all(15)),
            Text(songTitle, style: const TextStyle(color: Constants.primaryTextColor, fontSize: 15)),
            const Padding(padding: EdgeInsets.all(2)),
            Text(artist, style: const TextStyle(color: Constants.secondaryTextColor, fontSize: 12)),
            const Padding(padding: EdgeInsets.all(5),),
            const Spacer( flex: 3),
          ],
        ),
    );
  }
}

class PlayButton extends StatefulWidget {
  const PlayButton({super.key, required this.socket});

  final IO.Socket? socket;

  @override
  _PlayButtonState createState() => _PlayButtonState();
}

class _PlayButtonState extends State<PlayButton> {
  IO.Socket? socket;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    socket = widget.socket;

    socket!.on('subscribe', (data) {
      if ((data['response']['chromecastStatus']['playerState'] == 'PLAYING') != isPlaying) {
        setState(() {
          isPlaying = data['response']['chromecastStatus']['playerState'] == 'PLAYING';
        });
      }
    });

    socket!.on('getStatus', (data) {
      if(data['status'] == 'error'){
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
      width: 50,
      height: 50,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Constants.secondaryColor,
      ),
      child: IconButton(
        iconSize: 50,
        icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Constants.backgroundColor, size: 30),
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
  const SkipButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
        iconSize: 50,
        icon: const Icon(Icons.skip_next, color: Constants.secondaryColor, size: 30),
        onPressed: onPressed,
      );
  }
}

class PreviousButton extends StatelessWidget {
  const PreviousButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
        iconSize: 50,
        icon: const Icon(Icons.skip_previous, color: Constants.secondaryColor, size: 30),
        onPressed: onPressed,
      );
  }
}

class ChromecastSelected extends StatefulWidget {
  const ChromecastSelected({super.key, required this.socket});

  final IO.Socket? socket;

  @override
  _ChromecastSelectedState createState() => _ChromecastSelectedState();
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
    return Text(chromecastSelected, style: const TextStyle(color: Constants.primaryTextColor, fontSize: 15));
  }
}