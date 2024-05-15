import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'socket_service.dart';
import 'login.dart';
import 'home_page.dart';

void main() {


  runApp(ChangeNotifierProvider(
      create: (context) => SocketService(),
      child: const MyApp()
    )
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
      home: const HomePage(),
    );
  }
}