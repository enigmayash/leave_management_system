import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'leave_application.dart';
import 'package:leave_management_system/screens/LoginPage.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => LoginPage()));
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching data'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No data found'));
          }
          var userData = snapshot.data!.data();
          if (userData == null || !(userData is Map<String, dynamic>)) {
            return const Center(child: Text('Invalid user data'));
          }
          if (userData['role'] == 'teacher') {
            return const TeacherDashboard();
          } else {
            return const AdminDashboard();
          }
        },
      ),
    );
  }
}

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({Key? key});

  @override
  Widget build(BuildContext context) {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('leave_stats')
          .doc(userId)
          .get(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error fetching data'));
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('No data found'));
        }
        var leaveStats = snapshot.data!.data();
        if (leaveStats == null || !(leaveStats is Map<String, dynamic>)) {
          return const Center(child: Text('Invalid leave stats'));
        }
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total Leaves:'),
              Text('Medical: ${leaveStats['total_medical']}'),
              Text('Casual: ${leaveStats['total_casual']}'),
              const SizedBox(height: 20),
              const Text('Leaves Taken:'),
              Text('Medical: ${leaveStats['taken_medical']}'),
              Text('Casual: ${leaveStats['taken_casual']}'),
              const SizedBox(height: 20),
              const Text('Leaves Left:'),
              Text('Medical: ${leaveStats['left_medical']}'),
              Text('Casual: ${leaveStats['left_casual']}'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LeaveApplicationPage()));
                },
                child: const Text('Apply for Leave'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({Key? key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'teacher')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error fetching data'));
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('No data found'));
        }
        var teachers = snapshot.data!.docs;
        return ListView.builder(
          itemCount: teachers.length,
          itemBuilder: (context, index) {
            var teacher = teachers[index].data();
            if (teacher == null || !(teacher is Map<String, dynamic>)) {
              return const SizedBox.shrink(); // or handle invalid data
            }
            return ListTile(
              title: Text(teacher['name']),
              subtitle: Text(teacher['dept']),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TeacherLeaveDetailsPage(
                            teacherId: teachers[index].id)));
              },
            );
          },
        );
      },
    );
  }
}

class TeacherLeaveDetailsPage extends StatelessWidget {
  final String teacherId;

  const TeacherLeaveDetailsPage({Key? key, required this.teacherId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teacher Leave Details')),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('leave_stats')
            .doc(teacherId)
            .get(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching data'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No data found'));
          }
          var leaveStats = snapshot.data!.data();
          if (leaveStats == null || !(leaveStats is Map<String, dynamic>)) {
            return const Center(child: Text('Invalid leave stats'));
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Leaves:'),
                Text('Medical: ${leaveStats['total_medical']}'),
                Text('Casual: ${leaveStats['total_casual']}'),
                const SizedBox(height: 20),
                const Text('Leaves Taken:'),
                Text('Medical: ${leaveStats['taken_medical']}'),
                Text('Casual: ${leaveStats['taken_casual']}'),
                const SizedBox(height: 20),
                const Text('Leaves Left:'),
                Text('Medical: ${leaveStats['left_medical']}'),
                Text('Casual: ${leaveStats['left_casual']}'),
                const SizedBox(height: 20),
                const Text('Leave Requests:'),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('leaves')
                        .where('user_id', isEqualTo: teacherId)
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Center(child: Text('Error fetching data'));
                      }
                      if (!snapshot.hasData || snapshot.data == null) {
                        return const Center(child: Text('No data found'));
                      }
                      var leaves = snapshot.data!.docs;
                      return ListView.builder(
                        itemCount: leaves.length,
                        itemBuilder: (context, index) {
                          var leave = leaves[index].data();
                          if (leave == null || !(leave is Map<String, dynamic>)) {
                            return const SizedBox.shrink(); // or handle invalid data
                          }
                          return ListTile(
                            title: Text('${leave['type']} leave'),
                            subtitle: Text(
                                'From: ${DateFormat.yMMMd().format(leave['from_date'].toDate())} To: ${DateFormat.yMMMd().format(leave['to_date'].toDate())}'),
                            trailing: DropdownButton(
                              value: leave['status'],
                              onChanged: (newValue) {
                                FirebaseFirestore.instance
                                    .collection('leaves')
                                    .doc(leaves[index].id)
                                    .update({'status': newValue});
                              },
                              items: const [
                                DropdownMenuItem(
                                    value: 'pending', child: Text('Pending')),
                                DropdownMenuItem(
                                    value: 'approved', child: Text('Approved')),
                                DropdownMenuItem(
                                    value: 'rejected', child: Text('Rejected')),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
