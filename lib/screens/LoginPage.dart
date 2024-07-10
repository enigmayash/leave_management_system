import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:leave_management_system/screens/signup.dart';
import 'home.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _role = 'teacher';
  late String _identifier, _password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField(
                value: _role,
                onChanged: (newValue) {
                  setState(() {
                    _role = newValue!;
                  });
                },
                items: [
                  DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
                decoration: InputDecoration(labelText: 'Role'),
                validator: (value) => value == null ? 'Select role' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: _role == 'teacher' ? 'Phone' : 'Superkey'),
                validator: (value) => (value?.isEmpty ?? true) ?'Enter ${_role == 'teacher' ? 'phone number' : 'superkey'}' : null,
                onSaved: (value) => _identifier = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => (value?.isEmpty ?? true) ? 'Enter password' : null,
                onSaved: (value) => _password = value!,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: Text('Login'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()));
                },
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      try {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _role == 'teacher' ? _identifier + '@example.com' : _identifier + '@example.com',
          password: _password,
        );
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'An unknown error occurred')));
      }
    }
  }
}
