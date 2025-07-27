import 'package:cloud_firestore/cloud_firestore.dart';

/// 🔵 Admin Task Creation Service
class AdminTaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createTask({
    required String title,
    required String description,
    required String assignedToUid,
    required String createdByUid,
    required String dueDate,
  }) async {
    final creatorDoc =
    await _firestore.collection('users').doc(createdByUid).get();
    final creatorName = creatorDoc.data()?['name'] ?? 'Unknown Admin';

    final docRef = _firestore.collection('tasks').doc();
    final taskId = docRef.id;

    final taskData = {
      'taskId': taskId,
      'title': title,
      'description': description,
      'assignedTo': assignedToUid,
      'createdByUid': createdByUid,
      'createdByName': creatorName,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'dueDate': dueDate,
    };

    await docRef.set(taskData);
  }
}

/// 🔵 Admin Task Fetching & Deletion Service
class FirebaseTaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getTasksByAdminId(String adminId) {
    return _firestore
        .collection('tasks')
        .where('createdByUid', isEqualTo: adminId)
        .snapshots();
  }

  Future<void> deleteTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
  }

  Future<String> getEmployeeName(String employeeId) async {
    final doc = await _firestore.collection('users').doc(employeeId).get();
    if (doc.exists) {
      return doc['name'] ?? 'Unknown';
    } else {
      return 'Unknown';
    }
  }
}

/// 🔵 Admin User Management Service
class AdminManageUserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> isEmployeeIdAvailable(String id) async {
    final employeeDoc = await _firestore.collection('employee').doc(id).get();
    final userQuery = await _firestore
        .collection('users')
        .where('employee_id', isEqualTo: id)
        .limit(1)
        .get();

    return !employeeDoc.exists && userQuery.docs.isEmpty;
  }

  Future<void> addEmployeeId(String id) async {
    await _firestore.collection('employee').doc(id).set({
      'emp_id': id,
      'isUsed': false,
    });
  }

  Future<void> deleteEmployeeId(String id) async {
    await _firestore.collection('employee').doc(id).delete();
  }

  Stream<QuerySnapshot> streamEmployeeIds() {
    return _firestore.collection('employee').snapshots();
  }

  Future<String> getEmployeeNameByEmpId(String empId) async {
    final userQuery = await _firestore
        .collection('users')
        .where('employee_id', isEqualTo: empId)
        .limit(1)
        .get();
    if (userQuery.docs.isNotEmpty) {
      return userQuery.docs.first['name'] ?? 'Unknown';
    }
    return 'Unknown';
  }
}
