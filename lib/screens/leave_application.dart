import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LeaveApplicationPage extends StatefulWidget {
  @override
  _LeaveApplicationPageState createState() => _LeaveApplicationPageState();
}

class _LeaveApplicationPageState extends State<LeaveApplicationPage> {
  final _formKey = GlobalKey<FormState>();
  String _leaveType = 'Medical';
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Apply for Leave')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _leaveType,
                onChanged: (newValue) {
                  setState(() {
                    _leaveType = newValue!;
                  });
                },
                items: [
                  DropdownMenuItem(value: 'Medical', child: Text('Medical')),
                  DropdownMenuItem(value: 'Casual', child: Text('Casual')),
                ],
                decoration: InputDecoration(labelText: 'Type of Leave'),
                validator: (value) => value == null ? 'Select leave type' : null,
              ),
              ListTile(
                title: Text('From Date: ${_fromDate != null ? _fromDate!.toLocal().toString().split(' ')[0] : 'Select Date'}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _fromDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null && picked != _fromDate) {
                    setState(() {
                      _fromDate = picked;
                    });
                  }
                },
              ),
              ListTile(
                title: Text('To Date: ${_toDate != null ? _toDate!.toLocal().toString().split(' ')[0] : 'Select Date'}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _toDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null && picked != _toDate) {
                    setState(() {
                      _toDate = picked;
                    });
                  }
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _applyForLeave,
                child: Text('Apply'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _applyForLeave() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_fromDate == null || _toDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select the leave period')),
        );
        return;
      }

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('leaveRequests').add({
          'uid': user.uid,
          'leaveType': _leaveType,
          'fromDate': _fromDate,
          'toDate': _toDate,
          'status': 'Pending',
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Leave request submitted')),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not logged in')),
        );
      }
    }
  }
}
