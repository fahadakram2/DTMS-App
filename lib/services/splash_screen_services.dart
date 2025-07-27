import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseUserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Returns current user's name (for both admin and employee)
  Future<String?> getCurrentUserName() async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _firestore.collection('users').doc(user.uid).get();
      if (snapshot.exists) {
        return snapshot.data()?['name']; // Must have 'name' field in Firestore
      }
    }
    return null;
  }

  /// Optional: Get current user's role
  Future<String?> getCurrentUserRole() async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _firestore.collection('users').doc(user.uid).get();
      if (snapshot.exists) {
        return snapshot.data()?['role']; // Must have 'role' field (e.g., 'admin' or 'employee')
      }
    }
    return null;
  }
}
