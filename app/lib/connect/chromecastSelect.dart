import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../constants.dart';

class ChromecastSelect extends StatefulWidget {
  final IO.Socket? socket;
  const ChromecastSelect({super.key, required this.socket});

  @override
  _ChromecastSelectState createState() => _ChromecastSelectState();
}

class _ChromecastSelectState extends State<ChromecastSelect> {
  IO.Socket? socket;
  List<dynamic> chromecasts = [];

  @override
  void initState() {
    super.initState();
    socket = widget.socket;

    socket!.emit('getChromecasts');

    socket!.on('getChromecasts', (data) {
      setState(() {
        chromecasts = data['response'];
      });
    });

    socket!.on('newChromecast', (data) {
      setState(() {
        chromecasts.add(data);
      });
    });

    socket!.on('selectChromecast', (data) {
      if (data['status'] == 'ok'){
        socket!.emit('getCurrentSong');
        socket!.emit('getStatus');
      }
    });
  }

  void refreshChromecasts() {
    socket!.emit('getChromecasts');
  }

  void selectChromecast(String name) {
    socket!.emit('selectChromecast', name);
  }

  @override
  Widget build(BuildContext context) {
    return ChromecastOpener(chromecasts: chromecasts, getChromecasts: refreshChromecasts, selectChromecast: selectChromecast);
  }
}

class ChromecastOpener extends StatelessWidget {
  ChromecastOpener({super.key, required this.chromecasts, required this.getChromecasts, required this.selectChromecast});

  List<dynamic> chromecasts = [];
  final Function(String) selectChromecast;
  final Function getChromecasts;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: 50,
      icon: const Icon(Icons.cast,
          color: Constants.secondaryColor, size: 30),
      onPressed: () {
        showModalBottomSheet<void>(
          context: context,
          builder: (BuildContext context) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  const Text('Select a cast device'),
                  for (var chromecast in chromecasts)
                    ChromecastItem(
                      name: chromecast,
                      onPressed: () {
                        selectChromecast(chromecast);
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

class ChromecastItem extends StatelessWidget {
  const ChromecastItem({super.key, required this.name, required this.onPressed});
  final String name;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 300,
        height: 100,
        color: Constants.backgroundColor,
        child: Row(
          children: [
            const Icon(Icons.cast, color: Constants.primaryTextColor),
            SizedBox(
              width: 100,
              height: 100,
              child: Column(
                children: [
                  Text(name,
                      style:
                          const TextStyle(color: Constants.primaryTextColor)),
                  ElevatedButton(
                    onPressed: onPressed,
                    child: const Text('Select'),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}

// https://api.flutter.dev/flutter/material/showModalBottomSheet.html
