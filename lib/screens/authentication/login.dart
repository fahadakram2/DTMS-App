import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'signup.dart';
import 'forgot_password.dart';
import 'package:fyp_project1/screens/SharedScreen/PostLoginSplashScreen.dart';

class LoginScreen extends StatefulWidget {
  static bool _animationPlayed = false;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;

  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _colorAnimation = ColorTween(
      begin: Color(0xFF00C9A7),
      end: Color(0xFF1976D2),
    ).animate(_controller);

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);

      try {
        final userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final user = userCredential.user;
        if (user != null) {
          final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

          final userDoc = await userDocRef.get();
          final userData = userDoc.data();

          if (userData == null || !userData.containsKey('role')) {
            setState(() => _loading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("User role not defined. Contact support.")),
            );
            return;
          }

          final String role = userData['role'];
          final String userName = userData['name'] ?? 'User';
          final String roleId = userData['role_id'] ?? '';

          if (roleId.isEmpty) {
            setState(() => _loading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Employee ID not found. Contact support.")),
            );
            return;
          }

          setState(() => _loading = false);

          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 60, color: Color(0xFF388E3C)),
                    SizedBox(height: 15),
                    Text(
                      'Congratulations $userName!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF388E3C),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Welcome to DTMS!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.green[600],
                      ),
                    ),
                  ],
                ),
              ),
            );

            Future.delayed(Duration(seconds: 2), () {
              Navigator.of(context).pop();
              _controller.stop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => PostLoginSplashScreen(
                    role: role,
                    name: userName,
                    // Pass roleId if needed
                  ),
                ),
              );
            });
          });
        }
      } on FirebaseAuthException catch (e) {
        setState(() => _loading = false);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cancel_outlined, size: 60, color: Color(0xFFD32F2F)),
                  SizedBox(height: 15),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFFD32F2F),
                        fontWeight: FontWeight.w600,
                      ),
                      children: [
                        TextSpan(
                          text: 'Login failed\n',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: e.message ??
                              'Please check your credentials and try again.',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      }
    }
  }


  Widget _buildCustomLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF00C9A7), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          )
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        "DTMS",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildLogoAndTitle() {
    return Column(
      children: [
        FadeTransition(
          opacity: _fadeAnimation,
          child: _buildCustomLogo(),
        ),
        SizedBox(height: 15),
        FadeTransition(
          opacity: _fadeAnimation,
          child: AnimatedBuilder(
            animation: _colorAnimation,
            builder: (context, _) => Text(
              "DTMS",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: _colorAnimation.value,
                shadows: [
                  Shadow(
                      blurRadius: 8,
                      color: Colors.black26,
                      offset: Offset(2, 2)),
                ],
              ),
            ),
          ),
        ),
        Text(
          "Digital Task Management System",
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              _buildLogoAndTitle(),
              SizedBox(height: 30),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.teal.shade100, blurRadius: 10)
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email,
                        validator: (val) =>
                        val!.contains('@') ? null : 'Enter a valid email',
                      ),
                      SizedBox(height: 15),
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Password',
                        icon: Icons.lock,
                        obscure: _obscurePassword,
                        toggleVisibility: () => setState(() =>
                        _obscurePassword = !_obscurePassword),
                        validator: (val) => val!.length < 6
                            ? 'Min 6 characters required'
                            : null,
                      ),
                      SizedBox(height: 25),
                      ElevatedButton(
                        onPressed: _loading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF1976D2),
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: _loading
                            ? SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                            : Text("Login", style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                      SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          _controller.stop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ForgotPasswordScreen()),
                          );
                        },
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(color: Color(0xFF1976D2)),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _controller.stop();
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignupScreen()));
                        },
                        child: Text("Don't have an account? Sign Up",
                            style: TextStyle(color: Color(0xFF1976D2))),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    bool obscure = false,
    VoidCallback? toggleVisibility,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Color(0xFF00C9A7)),
        labelText: label,
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: toggleVisibility != null
            ? IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: toggleVisibility,
        )
            : null,
      ),
    );
  }
}
