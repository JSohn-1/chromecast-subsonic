import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../constants.dart';

class playlistSelect extends StatefulWidget {
  final IO.Socket? socket;
  playlistSelect({super.key, required this.socket});

  @override
  _playlistSelectState createState() => _playlistSelectState();
}

class _playlistSelectState extends State<playlistSelect> {
  IO.Socket? socket; 
  List<dynamic> playlists = [];

  @override
  void initState() {
    super.initState();
    socket = widget.socket;

    socket!.emit('getPlaylists');

    socket!.on('getPlaylists', (data) {
      setState(() {
        playlists = data['response'];
      });
    });
  }

  void refreshPlaylists() {
    socket!.emit('getPlaylists');
  }

  void selectPlaylist(String id) {
    socket!.emit('queuePlaylist', id);
  }

  @override
  Widget build(BuildContext context) {
    return PlaylistOpener(playlists: playlists, onPressedPlay: selectPlaylist, onPressedShuffle: () {}, onPressedRefresh: refreshPlaylists);
  }
}

class PlaylistOpener extends StatelessWidget {
  PlaylistOpener({super.key, required this.playlists, required this.onPressedPlay, required this.onPressedShuffle, required this.onPressedRefresh});
  
  List<dynamic> playlists = [];
  final VoidCallback onPressedPlay;
  final VoidCallback onPressedShuffle;
  final VoidCallback onPressedRefresh;
  
  @override
  Widget build(BuildContext context) {
    return IconButton(
        iconSize: 50,
        icon: const Icon(Icons.list, color: Constants.secondaryColor, size: 30),
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    const Text('Select a playlist'),
                    for (var playlist in playlists) 
                      PlaylistItem(
                        name: playlist['name'],
                        coverURL: "https://via.placeholder.com/50/", //"playlist['coverURL']" 
                        onPressedPlay: () {
                          print('pressed ${playlist['name']}');
                          onPressedPlay(playlist['id']);
                          // selectPlaylist(playlists[playlist]['id']);
                          // Navigator.pop(context);
                        },
                        onPressedShuffle: () {
                          print('shuffled ${playlist['name']}');
                          onPressedShuffle();
                          // selectPlaylist(playlists[playlist]['id']);
                          // Navigator.pop(context);
                        },
                        onPressedRefresh: () {
                          print('refreshed ${playlist['name']}');
                          onPressedRefresh();
                        },
                      ),
                  ],
                ),
              );
            },
          );
        }
      );
  }
}

class PlaylistItem extends StatelessWidget {
  const PlaylistItem({super.key, required this.name, required this.coverURL, required this.onPressedPlay, required this.onPressedShuffle, required this.onPressedRefresh});
  final String name;
  final String coverURL;
  final VoidCallback onPressedPlay;
  final VoidCallback onPressedShuffle;
  final VoidCallback onPressedRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 100,
      color: Constants.backgroundColor,
      child: Row(
        children: [
          const Padding(padding: EdgeInsets.all(5)),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(coverURL),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.all(5)),
          Text(name, style: const TextStyle(color: Constants.primaryTextColor)),
          const Spacer(flex: 1),
          PlaylistShuffleButton(onPressed: onPressedShuffle),
          PlaylistPlayButton(onPressed: onPressedPlay),
          const Padding(padding: EdgeInsets.all(5),)
        ],
      )
    );
  }
}

class PlaylistPlayButton extends StatelessWidget {
  const PlaylistPlayButton({super.key, required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
        iconSize: 50,
        icon: const Icon(Icons.play_arrow_rounded, color: Constants.secondaryColor, size: 30),
        onPressed: onPressed,
      );
  }
}

class PlaylistShuffleButton extends StatelessWidget {
  const PlaylistShuffleButton({super.key, required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
        iconSize: 50,
        icon: const Icon(Icons.shuffle, color: Constants.secondaryColor, size: 30),
        onPressed: onPressed,
      );
  }
}

class RefreshPlaylistsButton extends StatelessWidget {
  const RefreshPlaylistsButton({super.key, required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
        iconSize: 50,
        icon: const Icon(Icons.refresh, color: Constants.secondaryColor, size: 30),
        onPressed: onPressed,
      );
  }
}

// https://api.flutter.dev/flutter/material/showModalBottomSheet.html