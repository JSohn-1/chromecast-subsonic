import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:toastification/toastification.dart';

import '../constants.dart';

class ChromecastSelect extends StatefulWidget {
  final IO.Socket? socket;
  const ChromecastSelect({super.key, required this.socket});

  @override
  State<ChromecastSelect> createState() => _ChromecastSelectState();
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
      toastification.show(
          context: context,
          type: ToastificationType.info,
          style: ToastificationStyle.fillColored,
          title: const Text('New Chromecast found'),
          description: Text('Found: $data'),
          alignment: Alignment.topCenter,
          autoCloseDuration: const Duration(seconds: 4),
          boxShadow: lowModeShadow,
          dragToClose: true,
        );
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
    return ChromecastOpener(
      chromecasts: chromecasts, 
      getChromecasts: refreshChromecasts, 
      selectChromecast: selectChromecast
    );
  }
}

class ChromecastOpener extends StatelessWidget {
  const ChromecastOpener({
    super.key, 
    required this.chromecasts, 
    required this.getChromecasts, 
    required this.selectChromecast
  });

  final List<dynamic> chromecasts;
  final Function(String) selectChromecast;
  final Function getChromecasts;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: 50,
      icon: const Icon(Icons.speaker_group,
          color: Constants.secondaryColor, size: 40),
      onPressed: () {
        showModalBottomSheet<void>(
          context: context,
          backgroundColor: Constants.backgroundColor,
          builder: (BuildContext context) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  const Text(
                    'Select a Chromecast', 
                    style: TextStyle(
                      color: Constants.primaryTextColor, 
                      fontSize: 20
                    )),
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
  const ChromecastItem({
    super.key, 
    required this.name, 
    required this.onPressed
  });

  final String name;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 100,
        color: Constants.backgroundColor,
        child: Row(
          children: [
            const Padding(padding: EdgeInsets.all(5)),
            const Icon(
              Icons.speaker_rounded, 
              color: Constants.primaryTextColor, 
              size: 50
            ),
            const Padding(padding: EdgeInsets.all(5)),
            SizedBox(
              width: MediaQuery.of(context).size.width > 400 ? 
                200 : MediaQuery.of(context).size.width * 0.4,
              child: Text(name,
              overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Constants.primaryTextColor, 
                    fontSize: 15
                  )),
            ),
            const Spacer(flex: 1),
            IconButton(
              icon: const Icon(
                Icons.arrow_forward_ios, 
                color: Constants.primaryTextColor
              ),
              onPressed: () {
                onPressed();
                Navigator.pop(context);
              },
            ),
                  const Padding(padding: EdgeInsets.all(5)),
          ],
        ));
  }
}

class ChromecastPopup extends StatelessWidget {
  const ChromecastPopup({super.key, required this.chromecastName});

  final String chromecastName;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 200,
      color: Constants.primaryColor,
      child: Center(
        child: Text(chromecastName),
      ),
    );
  }
}
