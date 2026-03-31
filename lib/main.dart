import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:stoxy/Screens/login_screen.dart';
import 'firebase_options.dart'; // <--- Now imported properly

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stoxy',
      theme: ThemeData(primarySwatch: Colors.green),
      home: LoginScreen(), // ✅ REMOVED 'const'
    );
  }
}