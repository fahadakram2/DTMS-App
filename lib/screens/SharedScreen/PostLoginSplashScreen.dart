import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fyp_project1/screens/Admin/admin_dashboard.dart';
import 'package:fyp_project1/screens/Employee/employee_dashboard.dart';
import 'package:fyp_project1/screens/SharedScreen/theme_provider.dart';
import 'package:easy_localization/easy_localization.dart';

class PostLoginSplashScreen extends StatefulWidget {
  final String role;
  final String name;

  const PostLoginSplashScreen({
    Key? key,
    required this.role,
    required this.name,
  }) : super(key: key);

  @override
  State<PostLoginSplashScreen> createState() => _PostLoginSplashScreenState();
}

class _PostLoginSplashScreenState extends State<PostLoginSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0)
        .chain(CurveTween(curve: Curves.elasticOut))
        .animate(_scaleController);

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _scaleController.forward();
    _fadeController.forward();

    _loadPreferencesAndRedirect();
  }

  Future<void> _loadPreferencesAndRedirect() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final prefs = doc.data()?['preferences'] ?? {};

      final isDark = prefs['isDarkMode'] ?? false;
      final languageCode = prefs['languageCode'] ?? 'en';

      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      await themeProvider.setInitialTheme(isDark);
      await context.setLocale(Locale(languageCode));
    } catch (e) {
      debugPrint("⚠️ Failed to load theme/language: $e");
    }

    Timer(const Duration(seconds: 5), () {
      final targetScreen = widget.role.toLowerCase() == 'admin'
          ? const AdminDashboard()
          : const EmployeeDashboard();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => targetScreen),
      );
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.role.toLowerCase() == 'admin';
    final gradientColors = isAdmin
        ? [Colors.blue.shade200, Colors.white]
        : [Colors.green.shade200, Colors.white];

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      strokeWidth: 6,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isAdmin ? Colors.blue.shade700 : Colors.green.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Welcome, ${widget.name}!',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: isAdmin ? Colors.blue.shade800 : Colors.green.shade800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isAdmin
                        ? 'Preparing your Admin Dashboard...'
                        : 'Setting up your Employee Dashboard...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
