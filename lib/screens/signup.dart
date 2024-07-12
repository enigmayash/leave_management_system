import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _deptController = TextEditingController();
  String _role = 'teaching_staff';

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name')),
            TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone No')),
            TextField(
                controller: _idController,
                decoration: InputDecoration(labelText: 'ID')),
            TextField(
                controller: _deptController,
                decoration: InputDecoration(labelText: 'Department')),
            TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email')),
            TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true),
            DropdownButton<String>(
              value: _role,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _role = newValue;
                  });
                }
              },
              items: <String>['teaching_staff', 'hod', 'non_teaching_staff']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: () async {
                Map<String, dynamic> userData = {
                  'name': _nameController.text,
                  'phone': _phoneController.text,
                  'id': _idController.text,
                  'dept': _deptController.text,
                  'role': _role,
                  'CL_Taken': 0,
                  'CML_Taken': 0,
                  'RS_Taken': 0,
                };
                User? user = await _authService.signUpWithEmail(
                    _emailController.text, _passwordController.text, userData);
                if (user != null) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
