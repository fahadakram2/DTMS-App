import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart'; // required
import 'package:fyp_project1/screens/authentication/login.dart';

void handleLogout(BuildContext context) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const AlertDialog(
      content: Row(
        children: [
          CircularProgressIndicator(),
          SizedBox(width: 20),
          Text("Logging out..."),
        ],
      ),
    ),
  );

  // Optional delay for UI smoothness
  await Future.delayed(const Duration(seconds: 2));

  // Clear local theme preference (NOT from Firebase)
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('themeMode'); // if you stored dark/light mode here

  // Optional: reset via provider if used
  // Provider.of<ThemeProvider>(context, listen: false).resetTheme();

  // Sign out from Firebase
  await FirebaseAuth.instance.signOut();

  // Remove loading dialog
  Navigator.of(context).pop();

  // Navigate to login and clear all backstack
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => LoginScreen()),
        (Route<dynamic> route) => false,
  );
}
