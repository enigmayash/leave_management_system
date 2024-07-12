import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, int> hodLeaves = {'CL': 0, 'CML': 0, 'RS': 0};
  Map<String, int> hodLeavesLeft = {'CL': 15, 'CML': 10, 'RS': 2};

  @override
  void initState() {
    super.initState();
    _loadHodLeaves();
  }

  void _loadHodLeaves() async {
    String hodId = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot hodDoc =
        await _firestore.collection('users').doc(hodId).get();
    Map<String, dynamic> hodData = hodDoc.data() as Map<String, dynamic>;
    setState(() {
      hodLeaves = {
        'CL': (hodData['CL_Taken'] as num?)?.toInt() ?? 0,
        'CML': (hodData['CML_Taken'] as num?)?.toInt() ?? 0,
        'RS': (hodData['RS_Taken'] as num?)?.toInt() ?? 0,
      };
      hodLeavesLeft = {
        'CL': 15 - ((hodData['CL_Taken'] as num?)?.toInt() ?? 0),
        'CML': 10 - ((hodData['CML_Taken'] as num?)?.toInt() ?? 0),
        'RS': 2 - ((hodData['RS_Taken'] as num?)?.toInt() ?? 0),
      };
    });
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HOD Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('HOD Leave Details:',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                    'CL: Taken - ${hodLeaves['CL']}, Left - ${hodLeavesLeft['CL']}'),
                Text(
                    'CML: Taken - ${hodLeaves['CML']}, Left - ${hodLeavesLeft['CML']}'),
                Text(
                    'RS: Taken - ${hodLeaves['RS']}, Left - ${hodLeavesLeft['RS']}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _updateHodLeaves(context),
                  child: const Text('Update My Leave'),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('leaves')
                  .where('status', isEqualTo: 'pending')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView(
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    return FutureBuilder<DocumentSnapshot>(
                      future: _firestore
                          .collection('users')
                          .doc(data['user_id'])
                          .get(),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState ==
                            ConnectionState.done) {
                          Map<String, dynamic> userData =
                              userSnapshot.data!.data() as Map<String, dynamic>;
                          return Card(
                            child: ListTile(
                              title: Text(
                                  'Leave Application: ${data['teacher_name']} , ${data['role']}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Type: ${data['type']}, From: ${data['from_date']}, To: ${data['to_date']}'),
                                  Text('ID: ${userData['id']}'),
                                  Text(
                                      'CL Taken: ${(userData['CL_Taken'] as num?)?.toInt() ?? 0}, CML Taken: ${(userData['CML_Taken'] as num?)?.toInt() ?? 0}, RS Taken: ${(userData['RS_Taken'] as num?)?.toInt() ?? 0}'),
                                  Text(
                                      'CL Left: ${15 - ((userData['CL_Taken'] as num?)?.toInt() ?? 0)}, CML Left: ${10 - ((userData['CML_Taken'] as num?)?.toInt() ?? 0)}, RS Left: ${2 - ((userData['RS_Taken'] as num?)?.toInt() ?? 0)}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ElevatedButton(
                                    onPressed: () => approveLeave(document.id,
                                        data['user_id'], data['type']),
                                    child: const Text('Approve'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () => rejectLeave(document.id),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red),
                                    child: const Text('Reject'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return const CircularProgressIndicator();
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> approveLeave(
      String leaveId, String userId, String leaveType) async {
    await _firestore.runTransaction((transaction) async {
      DocumentReference leaveRef = _firestore.collection('leaves').doc(leaveId);
      DocumentReference userRef = _firestore.collection('users').doc(userId);

      DocumentSnapshot userSnapshot = await transaction.get(userRef);
      if (!userSnapshot.exists) {
        throw Exception("User does not exist!");
      }

      Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;
      String field = '${leaveType}_Taken';
      int currentLeaves = (userData[field] as num?)?.toInt() ?? 0;

      transaction.update(userRef, {field: currentLeaves + 1});
      transaction.update(leaveRef, {'status': 'approved'});
    });
  }

  Future<void> rejectLeave(String leaveId) async {
    await _firestore
        .collection('leaves')
        .doc(leaveId)
        .update({'status': 'rejected'});
  }

  void _updateHodLeaves(BuildContext context) async {
  String selectedLeaveType = 'CL'; // Initialize with default value
  await showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Text('Update Leave'),
          content: DropdownButton<String>(
            value: selectedLeaveType,
            hint: const Text('Select leave type'),
            items: ['CL', 'CML', 'RS'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedLeaveType = value!;
              });
            },
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Update'),
              onPressed: () async {
                String hodId = FirebaseAuth.instance.currentUser!.uid;
                String field = '${selectedLeaveType}_Taken';
                await _firestore
                    .collection('users')
                    .doc(hodId)
                    .update({field: FieldValue.increment(1)});
                _loadHodLeaves();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    ),
  );
}

}
