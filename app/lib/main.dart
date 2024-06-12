import 'package:app/player.dart';
import 'package:flutter/material.dart';

import 'socket_service.dart';
import 'login.dart';
import 'home_page.dart';

void main() {
  // PlayerContainer.init();
  runApp(
    const MyApp()
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Subsonic',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: SafeArea(
          child: Material(
            child: FutureBuilder<bool>(
              future: PersistentData.login(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data ?? false) {
                    return const HomePage();
                    // return const Text('udj');
                  } else {
                    return const Login();
                  }
                } else if (snapshot.hasError) {
              return Text(snapshot.error.toString());
                } else {
              return const CircularProgressIndicator();
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}