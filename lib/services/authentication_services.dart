import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Signup
  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
    required String roleId,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      // Store user data in Firestore
      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'role': role,
        'role_id': roleId,
      });

      if (role.toLowerCase() == 'admin') {
        await _firestore.collection('admin').doc(roleId).update({
          'isUsed': true,
        });
      } else if (role.toLowerCase() == 'employee') {
        await _firestore.collection('employee').doc(roleId).update({
          'isUsed': true,
        });
      }


      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Unexpected error: $e";
    }
  }

  // Login
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Unexpected error: $e";
    }
  }

  Future<String?> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser!.updatePassword(newPassword);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Unexpected error: $e";
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}
