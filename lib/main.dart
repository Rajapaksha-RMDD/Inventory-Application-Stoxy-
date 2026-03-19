import 'package:flutter/material.dart';
import 'package:stoxy/Screens/login_screen.dart'; // Make sure this path matches your folder structure

void main() {
  runApp(const StoxyApp());
}

class StoxyApp extends StatelessWidget {
  const StoxyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stoxy',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      // Setting LoginScreen as the starting page
      home: const LoginScreen(),
    );
  }
}