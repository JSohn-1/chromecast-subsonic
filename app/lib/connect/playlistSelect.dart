import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:toastification/toastification.dart';

import '../constants.dart';

class PlaylistSelect extends StatefulWidget {
  final IO.Socket? socket;
  const PlaylistSelect({super.key, required this.socket});

  @override
  State<PlaylistSelect> createState() => _PlaylistSelectState();
}

class _PlaylistSelectState extends State<PlaylistSelect> {
  IO.Socket? socket;
  List<dynamic> playlists = [];
  Map<String, String> playlistCovers = {};

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

    socket!.on('playQueue', (data) {
      if (data['status'] == 'error'){
        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.fillColored,
          title: const Text('Error selecting playlist'),
          description: Text(data['response']),
          alignment: Alignment.topCenter,
          autoCloseDuration: const Duration(seconds: 4),
          boxShadow: lowModeShadow,
          showProgressBar: true,
          dragToClose: true,
        );
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
  const PlaylistOpener(
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
        width: MediaQuery.of(context).size.width * 0.9,
        height: 100,
        color: Constants.backgroundColor,
        child: Row(
          children: [
            const Padding(padding: EdgeInsets.all(5)),
            const Icon(Icons.list, color: Constants.secondaryColor, size: 50),
            const Padding(padding: EdgeInsets.all(5)),
            SizedBox(
              width: MediaQuery.of(context).size.width > 400
                  ? 100
                  : MediaQuery.of(context).size.width * 0.4,
              child: Text(name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Constants.primaryTextColor, fontSize: 15)),
            ),
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
      icon: const Icon(Icons.play_arrow_rounded,
          color: Constants.secondaryColor, size: 35),
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
      icon:
          const Icon(Icons.shuffle, color: Constants.secondaryColor, size: 35),
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
