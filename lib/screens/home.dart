import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'leave_application.dart';

class HomePage extends StatelessWidget {
  void _logout(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  Navigator.of(context).pushReplacementNamed('/login');
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard'),
      actions: [
    IconButton(
      icon: Icon(Icons.logout),
      onPressed: () => _logout(context),
    ),
  ],),
      
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Text('No user data found');
          }

          Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};

          int total_CL = 15;
          int total_CML = 10;
          int total_RS = 2;
          int CL_Taken = userData['CL-Taken'] ?? 0;
          int CML_Taken = userData['CML-Taken'] ?? 0;
          int RS_Taken = userData['RS-Taken'] ?? 0;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${userData['name'] ?? 'N/A'}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Phone: ${userData['phone'] ?? 'N/A'}'),
                Text('Department: ${userData['dept'] ?? 'N/A'}'),
                SizedBox(height: 16),
                Text('Leave Details:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('CL:'),
                Text('  Total: $total_CL'),
                Text('  Taken: $CL_Taken'),
                Text('  Remaining: ${total_CL - CL_Taken}'),
                SizedBox(height: 8),
                Text('CML:'),
                Text('  Total: $total_CML'),
                Text('  Taken: $CML_Taken'),
                Text('  Remaining: ${total_CML - CML_Taken}'),
                SizedBox(height: 24),
                Text('RS:'),
                Text('  Total: $total_RS'),
                Text('  Taken: $RS_Taken'),
                Text('  Remaining: ${total_RS - RS_Taken}'),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LeaveApplicationPage()),
                    );
                  },
                  child: Text('Apply for Leave'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}