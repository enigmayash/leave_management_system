import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:leave_management_system/screens/signup.dart';
import 'package:leave_management_system/screens/LoginPage.dart';
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
      title: 'Leave Management System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}
