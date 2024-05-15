import "package:flutter/material.dart";
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart';

import 'socket_service.dart';
import 'player.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    final TextEditingController domainController = TextEditingController();
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    // Send domain, username, and password to the server
    void sendCredentials() async {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const AlertDialog(
        title: Text('Connecting'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Connecting to server...'),
          ],
        ),
          );
        },
      );

      final domain = domainController.text;
      final username = usernameController.text;
      final password = passwordController.text;

      socketService.createSocketConnection(domain);

      final socket = socketService.socket;

      socket.onConnect( (_) async {
        print('Connected to server!');
        final result = await http.post(
          Uri.parse('$domain/subsonic/login?&uuid=${socket.id}&username=$username&password=$password'),
        );

        print(result);

        Navigator.pop(context);

        if (result.statusCode != 200) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Login Failed'),
                content: const Text('Invalid username or password'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop(true);
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Player()),
          );
        }
    });

      

      // socket.on('connect', (_) {
      //   socket.emit('login', [username, password]);
      // });

      // socket.on('login', (data) {
      //   Navigator.pop(context);
      //   if (data['success']) {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (context) => const Player()),
      //     );
      //   } else {
      //     socketService.disposeSocketConnection();
      //     socket.off('connect');
      //     socket.off('login');

      //     showDialog(
      //       context: context,
      //       builder: (BuildContext context) {
      //         return AlertDialog(
      //           title: const Text('Login Failed'),
      //           content: const Text('Invalid username or password'),
      //           actions: <Widget>[
      //             TextButton(
      //               onPressed: () {
      //                 Navigator.of(context, rootNavigator: true).pop(true);
      //               },
      //               child: const Text('OK'),
      //             ),
      //           ],
      //         );
      //       },
      //     );
      //   }
      // });
    }

    return Scaffold(
      body: Column(
       children: [
          TextField(
          controller: domainController,
          decoration: const InputDecoration(
            labelText: 'Domain',
          ),
          ),
          TextField(
          controller: usernameController,
          decoration: const InputDecoration(
            labelText: 'Username',
          ),
          ),
          TextField(
          controller: passwordController,
          decoration: const InputDecoration(
            labelText: 'Password',
          ),
          ),
          ElevatedButton(
          onPressed: sendCredentials,
          child: const Text('Send'),
          ),
        ],
      ),
    );
  }

}