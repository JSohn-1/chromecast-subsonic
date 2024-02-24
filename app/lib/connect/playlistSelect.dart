import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../constants.dart';

class PlaylistSelect extends StatefulWidget {
  final IO.Socket? socket;
  const PlaylistSelect({super.key, required this.socket});

  @override
  _playlistSelectState createState() => _playlistSelectState();
}

class _playlistSelectState extends State<PlaylistSelect> {
  IO.Socket? socket;
  List<dynamic> playlists = [];
  Map<String, String> playlistCovers = {};

  @override
  void initState() {
    super.initState();
    socket = widget.socket;

    socket!.emit('getPlaylists');

    socket!.on('getPlaylists', (data) {
      for (var playlist in data['response']) {
        socket!.emit('getPlaylistCoverURL', playlist['id']);
      }
      setState(() {
        playlists = data['response'];
      });
    });

    socket!.on('getPlaylistCoverURL', (data) {
        print(data);

        playlistCovers[data['id']] = (data['response']['url']);
        if (playlistCovers.length == playlists.length) {
          setState(() {});
        }
    });
  }

  void refreshPlaylists() {
    socket!.emit('getPlaylists');
  }

  void selectPlaylist(String id) {
    socket!.emit('queuePlaylist', id);
  }

  void selectPlaylistShuffle(String id) {
    socket!.emit('queuePlaylistShuffle', id);
  }

  @override
  Widget build(BuildContext context) {
    return PlaylistOpener(
        playlists: playlists,
        playlistsCovers: playlistCovers,
        onPressedPlay: selectPlaylist,
        onPressedShuffle: selectPlaylistShuffle,
        onPressedRefresh: refreshPlaylists);
  }
}

class PlaylistOpener extends StatelessWidget {
  PlaylistOpener(
      {super.key,
      required this.playlists,
      required this.playlistsCovers,
      required this.onPressedPlay,
      required this.onPressedShuffle,
      required this.onPressedRefresh});

  final List<dynamic> playlists;
  final Map<String, String> playlistsCovers;
  final Function(String) onPressedPlay;
  final Function(String) onPressedShuffle;
  final VoidCallback onPressedRefresh;

  @override
  Widget build(BuildContext context) {
    return IconButton(
        iconSize: 50,
        icon: const Icon(Icons.list, color: Constants.secondaryColor, size: 40),
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
                        onPressedPlay: () {
                          onPressedPlay(playlist['id']);
                          Navigator.pop(context);
                        },
                        onPressedShuffle: () {
                          onPressedShuffle(playlist['id']);
                          Navigator.pop(context);
                        },
                        onPressedRefresh: () {
                          onPressedRefresh();
                          Navigator.pop(context);
                        },
                      ),
                  ],
                ),
              );
            },
          );
        });
  }
}

class PlaylistItem extends StatelessWidget {
  const PlaylistItem(
      {super.key,
      required this.name,
      required this.onPressedPlay,
      required this.onPressedShuffle,
      required this.onPressedRefresh});
  final String name;
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
            Text(name,
                style: const TextStyle(color: Constants.primaryTextColor)),
            const Spacer(flex: 1),
            PlaylistShuffleButton(onPressed: onPressedShuffle),
            PlaylistPlayButton(onPressed: onPressedPlay),
            const Padding(
              padding: EdgeInsets.all(5),
            )
          ],
        ));
  }
}

class PlaylistPlayButton extends StatelessWidget {
  const PlaylistPlayButton({super.key, required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: 50,
      icon: const Icon(Icons.play_arrow_rounded,
          color: Constants.secondaryColor, size: 30),
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
      icon:
          const Icon(Icons.shuffle, color: Constants.secondaryColor, size: 30),
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
      icon:
          const Icon(Icons.refresh, color: Constants.secondaryColor, size: 30),
      onPressed: onPressed,
    );
  }
}

// https://api.flutter.dev/flutter/material/showModalBottomSheet.html
