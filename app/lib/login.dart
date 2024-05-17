import 'package:app/home_page.dart';
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
    final TextEditingController domainController = TextEditingController();
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    // Send domain, username, and password to the server
    void sendCredentials() async {
      if (domainController.text.isEmpty || usernameController.text.isEmpty || passwordController.text.isEmpty) {
        return;
      }

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

      SocketService.createSocketConnection(domain);

      final socket = SocketService.socket;

      socket.onConnect( (_) async {
        final result = await http.post(
          Uri.parse('$domain/subsonic/login?&uuid=${socket.id}&username=$username&password=$password'),
        );

        Navigator.pop(context);

        if (result.statusCode != 200) {
          SocketService.disposeSocketConnection();
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
          await PersistentData.saveLogin(domain, username, password);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      });
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