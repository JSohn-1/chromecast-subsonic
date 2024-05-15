// // ignore_for_file: unnecessary_const

// import 'dart:io';

// import 'package:app/socket_service.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:http/http.dart' as http;

// import 'package:app/login.dart';
// import 'package:app/player.dart';
// import 'package:provider/provider.dart';
// import 'config.dart';

// void main() {
//   setUpAll(() {
//     HttpOverrides.global = null;
//   });
//   testWidgets('Login Test', (WidgetTester tester) async {
//     // Build the login widget
//     await tester.pumpWidget(
//       MaterialApp(
//         home: ChangeNotifierProvider(
//       create: (context) => SocketService(),
//       child: const Login()
//     ),
//       ),
//     );
  
//     // Enter details into the fields
//     final domainField = find.byWidgetPredicate((widget) => widget is TextField && widget.decoration?.labelText == 'Domain');
//     final userField = find.byWidgetPredicate((widget) => widget is TextField && widget.decoration?.labelText == 'Username');
//     final passwordField = find.byWidgetPredicate((widget) => widget is TextField && widget.decoration?.labelText == 'Password');

//     expect(domainField, findsOneWidget); 
//     expect(userField, findsOneWidget); 
//     expect(passwordField, findsOneWidget);

//     await tester.enterText(domainField, Config.API_URL);
//     await tester.enterText(userField, Config.API_USER);
//     await tester.enterText(passwordField, Config.API_PASSWORD);

//     // Attempt to build the player menu
//     final loginButton = find.widgetWithText(ElevatedButton, 'Send');

//     expect(loginButton, findsOneWidget);

//     await tester.tap(loginButton);
//     await tester.pump();

//     print('Login Test Passed');

//     // Send HTTP request to subsonic/ping
//     final response = await http.post(Uri.parse('${Config.API_URL}/subsonic/ping'));
//     expect(response.statusCode, 200);
//   });
// }