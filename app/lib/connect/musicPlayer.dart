// Create the music screen which will take in the parameters of the song title, artist, and album art. 

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MusicPlayer extends StatelessWidget {
  const MusicPlayer({super.key, required this.title, required this.artist, required this.albumArt});

  final String title;
  final String artist;
  final String albumArt;

  @override
  Widget build(BuildContext context) {
    return Column(
        children: <Widget>[
          Image.network(albumArt, width: 300, height: 300),
          Text(title),
          Text(artist),
        ],
      );
  }
}