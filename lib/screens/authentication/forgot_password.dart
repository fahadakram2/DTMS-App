import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final email = _emailController.text.trim();

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      setState(() => _loading = false);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.email_outlined, size: 60, color: Color(0xFF388E3C)),
              SizedBox(height: 15),
              Text(
                'Reset Link Sent!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Please check your email to reset your password.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _loading = false);

      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email.';
          break;
        case 'invalid-email':
          message = 'The email address is badly formatted.';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Try again later.';
          break;
        default:
          message = e.message ?? 'Something went wrong. Please try again.';
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 60, color: Color(0xFFD32F2F)),
              SizedBox(height: 15),
              Text(
                'Error',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFD32F2F)),
              ),
              SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('Forgot Password', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF00C9A7),
        leading: BackButton(color: Colors.white),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          width: size.width * 0.85,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    "Reset Password",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 15),
                  Text(
                    "Enter your registered email and we'll send you a link to reset your password.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                      if (val == null || !emailRegex.hasMatch(val.trim())) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email, color: Color(0xFF00C9A7)),
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: _loading ? null : _sendResetEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1976D2), // Blue button
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _loading
                        ? SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : Text("Send Reset Link", style: TextStyle(fontSize: 18, color: Colors.white)),
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
