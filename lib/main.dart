import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:leave_management_system/screens/LoginPage.dart';
import 'package:leave_management_system/screens/signup.dart';
import 'package:leave_management_system/screens/home.dart';
import 'package:leave_management_system/screens/admin_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leave Management System',
      initialRoute: '/login',
      routes: {
        '/signup': (context) => SignUpPage(),
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/admin': (context) => AdminPage(),
      },
    );
  }
}