import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'leave_application.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Text('No user data found');
          }

          Map<String, dynamic> userData =
              snapshot.data!.data() as Map<String, dynamic>? ?? {};

          int totalCl = 15;
          int totalCml = 10;
          int totalRs = 2;
          int clTaken = userData['CL_Taken'] ?? 0;
          int cmlTaken = userData['CML_Taken'] ?? 0;
          int rsTaken = userData['RS_Taken'] ?? 0;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${userData['name'] ?? 'N/A'}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Phone: ${userData['phone'] ?? 'N/A'}'),
                Text('Department: ${userData['dept'] ?? 'N/A'}'),
                const SizedBox(height: 16),
                const Text('Leave Details:',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('CL:'),
                Text('  Total: $totalCl'),
                Text('  Taken: $clTaken'),
                Text('  Remaining: ${totalCl - clTaken}'),
                const SizedBox(height: 8),
                const Text('CML:'),
                Text('  Total: $totalCml'),
                Text('  Taken: $cmlTaken'),
                Text('  Remaining: ${totalCml - cmlTaken}'),
                const SizedBox(height: 24),
                const Text('RS:'),
                Text('  Total: $totalRs'),
                Text('  Taken: $rsTaken'),
                Text('  Remaining: ${totalRs - rsTaken}'),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LeaveApplicationPage()),
                    );
                  },
                  child: const Text('Apply for Leave'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
