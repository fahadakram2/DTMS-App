import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmployeeTaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get tasks assigned to the employee
  Stream<QuerySnapshot> getTasksForEmployee(String employeeId) {
    return _firestore
        .collection('tasks')
        .where('assignedTo', isEqualTo: employeeId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Update task status to completed
  Future<void> markTaskAsCompleted(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).update({
      'status': 'completed',
    });
  }

  // Send a message to admin from the employee
  Future<void> sendMessageToAdmin(String taskId, String message) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Fetch the real name from Firestore users collection
    final userDoc =
    await _firestore.collection('users').doc(user.uid).get();

    final senderName = userDoc.data()?['name'] ?? 'Employee';

    await _firestore
        .collection('tasks')
        .doc(taskId)
        .collection('messages')
        .add({
      'senderUid': user.uid,
      'senderName': senderName,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

}
