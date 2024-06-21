import 'dart:async';
import 'package:app/player.dart';
import 'package:app/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';


class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {

  @override
  void initState() {
    PlayerContainer.currentSongStream.listen((event) {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      width: MediaQuery.of(context).size.width - 20,
      decoration:  BoxDecoration(
        color:  const Color.fromARGB(20, 255, 255, 255),
        borderRadius: BorderRadius.circular(10),
      ),
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            PlayerContainer.currentSong != null
                ? '${SocketService.socket.io.uri}/subsonic/cover?id=${PlayerContainer.currentSong?.id}&uuid=${SocketService.socket.id}'
                : 'https://via.placeholder.com/45',
            width: 45,
            height: 45,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(PlayerContainer.currentSong?.title ?? 'Not Playing',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              Text(PlayerContainer.currentSong?.artist ?? '',
                  style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const Spacer(),
          const MiniSpeakerButton(),
          const MiniPlayButton(),
        ],
      ),
    );
  }
}

class MiniPlayButton extends StatefulWidget {
  const MiniPlayButton({super.key});

  @override
  State<MiniPlayButton> createState() => _MiniPlayButtonState();
}

class _MiniPlayButtonState extends State<MiniPlayButton> {
  bool playing = false;

  StreamSubscription<bool>? _playbackSubscription;

  @override
  void initState() {
    _playbackSubscription = PlayerContainer.player.playingStream.listen((event) {
      setState(() {
        playing = event;
      });
    });

    SocketService.on('resume', (data) async {
      if (PlayerContainer.playing) {
        PlayerContainer.player.play();
        return;
      }
      playing = true;
      setState(() {});
    });

    SocketService.on('pause', (data) async {
      if (PlayerContainer.playing) {
        PlayerContainer.player.pause();
        return;
      }
      playing = false;
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    _playbackSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(playing ? Icons.pause : Icons.play_arrow),
      color: PlayerContainer.currentSong != null ? Colors.white : Colors.grey,
      iconSize: 40,
      onPressed: () {
        if (PlayerContainer.currentSong == null) return;

        if (playing) {
          if (PlayerContainer.playing) {
            PlayerContainer.player.pause();
            return;
          }

          playing = false;
          SocketService.socket.emit('pause');
          setState(() {});

        } else {
          if (PlayerContainer.playing) {
            PlayerContainer.player.play();
            return;
          }

          playing = true;
          SocketService.socket.emit('resume');
          setState(() {});
        }
      },
    );
  }
}

class MiniSpeakerButton extends StatelessWidget {
  const MiniSpeakerButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.speaker_group_rounded),
      color: Colors.white,
      onPressed: () {
        showMaterialModalBottomSheet(
        context: context,
        builder: (context) => Container(),
        );
      },
    );
  }
}
