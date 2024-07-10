import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  String _role = 'teacher';
  late String _name;
  late String _phone;
  late String _id;
  late String _dept;
  late String _superkey;
  late String _password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
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
              if (_role == 'teacher') ...[
                TextFormField(
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (value) => (value?.isEmpty ?? true) ? 'Enter name' : null,
                  onSaved: (value) => _name = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Phone'),
                  validator: (value) => (value?.isEmpty ?? true) ? 'Enter phone number' : null,
                  onSaved: (value) => _phone = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'ID'),
                  validator: (value) => (value?.isEmpty ?? true) ? 'Enter ID' : null,
                  onSaved: (value) => _id = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Department'),
                  validator: (value) => (value?.isEmpty ?? true) ? 'Enter department' : null,
                  onSaved: (value) => _dept = value!,
                ),
              ] else ...[
                TextFormField(
                  decoration: InputDecoration(labelText: 'Superkey'),
                  validator: (value) => (value?.isEmpty ?? true) ? 'Enter superkey' : null,
                  onSaved: (value) => _superkey = value!,
                ),
              ],
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => (value?.isEmpty ?? true) ? 'Enter password' : null,
                onSaved: (value) => _password = value!,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signUp,
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _signUp() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _role == 'teacher' ? _phone + '@example.com' : _superkey + '@example.com',
          password: _password,
        );

        if (userCredential.user != null) {
          await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
            'role': _role,
            if (_role == 'teacher') ...{
              'name': _name,
              'phone': _phone,
              'id': _id,
              'dept': _dept,
            } else ...{
              'superkey': _superkey,
            },
          });

          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
        }
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'An unknown error occurred')),
        );
      }
    }
  }
}
