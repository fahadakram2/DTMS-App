import 'dart:async';
import 'package:flutter/material.dart';
import '../authentication/login.dart'; // Replace with your login page path

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.2)
        .chain(CurveTween(curve: Curves.easeInOutBack))
        .animate(_controller);

    _opacityAnimation = Tween<double>(begin: 0, end: 1)
        .chain(CurveTween(curve: Curves.easeIn))
        .animate(_controller);

    _controller.forward();

    Timer(Duration(seconds: 7), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColor = Colors.deepPurple;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFB388FF), // soft purple
              Color(0xFF8C9EFF), // soft blue
              Color(0xFF80D8FF), // soft teal
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: appColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: appColor.withOpacity(0.4),
                            blurRadius: 25,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.task_alt,
                        size: 70,
                        color: appColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Opacity(
                    opacity: _opacityAnimation.value,
                    child: Column(
                      children: [
                        Text(
                          "Task Manager",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: appColor,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Organize. Prioritize. Succeed.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
