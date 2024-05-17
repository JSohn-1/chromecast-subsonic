import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'socket_service.dart';
import 'login.dart';
import 'home_page.dart';

void main() {
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
      // home: const Login(),
      home: FutureBuilder<bool>(
        future: PersistentData.login(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data ?? false) {
              print(snapshot.data);
              return const HomePage();
            } else {
              return const Login();
            }
          } else if (snapshot.hasError) {
        return const Text('Error');
          } else {
        return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}