import 'dart:async';

import 'package:app/home_page.dart';
import 'package:app/player.dart';
import "package:flutter/material.dart";
import 'package:http/http.dart' as http;

import 'socket_service.dart';

class Login extends StatelessWidget {
  const Login({super.key});

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

      Future<bool> connect = SocketService.createSocketConnection(domain);

      final result = await Future.any([connect, Future.delayed(const Duration(seconds: 5), () => false)]);

      if (result == false) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Connection Failed'),
              content: const Text('Could not connect to server'),
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
        return;
      }

      final socket = SocketService.socket;

      final res = await http.post(
        Uri.parse('$domain/subsonic/login?&uuid=${socket.id}&username=$username&password=$password'),
      );

      Navigator.pop(context);

      if (res.statusCode != 200) {
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
        await PlayerContainer.init();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Material(child: HomePage())),
        );
      }

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