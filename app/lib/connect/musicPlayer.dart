// Create the music screen which will take in the parameters of the song title, artist, and album art. 
import 'package:flutter/material.dart';

import '../constants.dart';

class MusicPlayer extends StatelessWidget {
  const MusicPlayer({super.key, required this.title, required this.artist, required this.albumArt, required this.isPlaying, required this.onPressedPlay, required this.onPressedSkip});

  final String title;
  final String artist;
  final String albumArt;
  final bool isPlaying;

  final VoidCallback onPressedPlay;
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
            Image.network(albumArt, width: 250, height: 250),
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
                PlayButton(isPlaying: isPlaying, onPressed: onPressedPlay),
                const Padding(padding: EdgeInsets.all(5),),
                SkipButton(onPressed: onPressedSkip)
                ]),
            const Spacer( flex: 3),
          ],
        ),
    );
  }
}

class PlayButton extends StatelessWidget {
  const PlayButton({super.key, required this.isPlaying, required this.onPressed});

  final bool isPlaying;
  final VoidCallback onPressed;

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
        onPressed: onPressed,
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