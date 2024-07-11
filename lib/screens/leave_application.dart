import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class LeaveApplicationPage extends StatefulWidget {
  @override
  _LeaveApplicationPageState createState() => _LeaveApplicationPageState();
}

class _LeaveApplicationPageState extends State<LeaveApplicationPage> {
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();
  String _leaveType = 'medical';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Apply for Leave')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _leaveType,
              onChanged: (String? newValue) {
                setState(() {
                  _leaveType = newValue!;
                });
              },
              items: <String>['medical', 'casual']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            TextField(
              controller: _fromDateController,
              decoration: InputDecoration(labelText: 'From Date'),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  setState(() {
                    _fromDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                  });
                }
              },
            ),
            TextField(
              controller: _toDateController,
              decoration: InputDecoration(labelText: 'To Date'),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  setState(() {
                    _toDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                  });
                }
              },
            ),
            ElevatedButton(
              onPressed: () {
                String userId = FirebaseAuth.instance.currentUser!.uid;
                _firestore.collection('leaves').add({
                  'user_id': userId,
                  'type': _leaveType,
                  'from_date': _fromDateController.text,
                  'to_date': _toDateController.text,
                  'status': 'pending',
                });
                Navigator.pushReplacementNamed(context, '/home');
              },
              child: Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
}