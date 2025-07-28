// services/setting_services.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Save user's theme preference
  Future<void> saveThemePreference(bool isDarkMode) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore.collection('users').doc(uid).set({
      'preferences': {
        'isDarkMode': isDarkMode,
      }
    }, SetOptions(merge: true));
  }

  ///  Load user's theme preference (default = false)
  Future<bool> loadThemePreference() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;

    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data()?['preferences']?['isDarkMode'] ?? false;
  }

  ///  Save user's language preference
  Future<void> saveLanguagePreference(String languageCode) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore.collection('users').doc(uid).set({
      'preferences': {
        'languageCode': languageCode,
      }
    }, SetOptions(merge: true));
  }

  ///  Load user's language preference (default = 'en')
  Future<String> loadLanguagePreference() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return 'en';

    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data()?['preferences']?['languageCode'] ?? 'en';
  }
}
