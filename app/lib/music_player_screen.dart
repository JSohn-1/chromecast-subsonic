import 'package:app/mini_player.dart';
import 'package:app/player.dart';
import 'package:app/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class MusicPlayerScreen extends StatelessWidget {
  const MusicPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SlidingUpPanel(
          controller: PanelController(),
          maxHeight: MediaQuery.of(context).size.height,
          minHeight: 71,
          defaultPanelState: PanelState.OPEN,
          backdropEnabled: true,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          onPanelClosed: () => Navigator.of(context).pop(),
          panel: Material(
            child: Container(
              color: const Color.fromARGB(255, 18, 18, 18),
              child: Column(
                children: [
                  const Padding(padding: EdgeInsets.all(5)),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                    ),
                    height: 5,
                    width: 50,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 50),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hero(
                        tag: 'albumCover',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: PlayerContainer.currentSong != null
                              ? Image.network(
                                  '${SocketService.socket.io.uri}/subsonic/cover?id=${PlayerContainer.currentSong?.id}&uuid=${SocketService.socket.id}',
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  height:
                                      MediaQuery.of(context).size.width * 0.8,
                                )
                              : SvgPicture.asset(
                                  'assets/svgs/defaultAlbumCover.svg',
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  height:
                                      MediaQuery.of(context).size.width * 0.9),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 40),
                      ),
                      Text(PlayerContainer.currentSong?.title ?? 'Not Playing',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold)),
                      Text(PlayerContainer.currentSong?.artist ?? '',
                          style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                  ),
                  const MiniPlayerControls(),
                ],
              ),
            ),
          )),
    );
  }
}
