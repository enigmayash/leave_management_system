import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class LeaveApplicationPage extends StatefulWidget {
  const LeaveApplicationPage({super.key});

  @override
  _LeaveApplicationPageState createState() => _LeaveApplicationPageState();
}

class _LeaveApplicationPageState extends State<LeaveApplicationPage> {
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();
  String _leaveType = 'CL';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Apply for Leave')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _leaveType,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _leaveType = newValue;
                  });
                }
              },
              items: <String>['CL', 'CML', 'RS']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            TextField(
              controller: _fromDateController,
              decoration: const InputDecoration(labelText: 'From Date'),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  setState(() {
                    _fromDateController.text =
                        DateFormat('yyyy-MM-dd').format(pickedDate);
                  });
                }
              },
            ),
            TextField(
              controller: _toDateController,
              decoration: const InputDecoration(labelText: 'To Date'),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  setState(() {
                    _toDateController.text =
                        DateFormat('yyyy-MM-dd').format(pickedDate);
                  });
                }
              },
            ),
            ElevatedButton(
              onPressed: () async {
                String userId = _auth.currentUser!.uid;
                DocumentSnapshot userDoc =
                    await _firestore.collection('users').doc(userId).get();
                Map<String, dynamic> userData =
                    userDoc.data() as Map<String, dynamic>;
                await _firestore.collection('leaves').add({
                  'user_id': userId,
                  'teacher_name': userData['name'],
                  'teacher_id': userData['id'],
                  'role': userData['role'],
                  'type': _leaveType,
                  'from_date': _fromDateController.text,
                  'to_date': _toDateController.text,
                  'status': 'pending',
                });
                Navigator.pushReplacementNamed(context, '/home');
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
}
