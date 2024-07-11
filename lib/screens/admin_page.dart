import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminPage extends StatelessWidget {
  void _logout(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  Navigator.of(context).pushReplacementNamed('/login');
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Dashboard'),
       actions: [
    IconButton(
      icon: Icon(Icons.logout),
      onPressed: () => _logout(context),
    ),
  ],),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('leaves').where('status', isEqualTo: 'pending').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              return ListTile(
                title: Text('Leave Application'),
                subtitle: Text('Type: ${data['type']}, From: ${data['from_date']}, To: ${data['to_date']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () => approveLeave(document.id, data['user_id'], data['type']),
                      child: Text('Approve'),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => rejectLeave(document.id),
                      child: Text('Reject'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Future<void> approveLeave(String leaveId, String userId, String leaveType) async {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentReference leaveRef = FirebaseFirestore.instance.collection('leaves').doc(leaveId);
      DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userId);

      DocumentSnapshot userSnapshot = await transaction.get(userRef);
      if (!userSnapshot.exists) {
        throw Exception("User does not exist!");
      }

      Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
      String field = leaveType == 'casual' ? 'casualLeavesTaken' : 'medicalLeavesTaken';
      int currentLeaves = userData[field] ?? 0;

      transaction.update(userRef, {field: currentLeaves + 1});
      transaction.update(leaveRef, {'status': 'approved'});
    });
  }

  Future<void> rejectLeave(String leaveId) async {
    await FirebaseFirestore.instance.collection('leaves').doc(leaveId).update({'status': 'rejected'});
  }
}