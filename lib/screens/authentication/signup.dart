import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';

class SignupScreen extends StatefulWidget {
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _roleIdController = TextEditingController();

  String _selectedRole = 'Select Role';
  bool _loading = false;
  bool _obscurePassword = true;

  final List<String> roles = ['Select Role', 'admin', 'employee'];

  // 🔒 Password must be at least 6 characters with letters and digits
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Enter password';
    if (value.length < 6) return 'Minimum 6 characters required';
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(value)) {
      return 'Must include letters and numbers';
    }
    return null;
  }

  // ✅ Check if entered Admin ID exists in `admin_ids` collection
  Future<bool> _isAdminIdValid(String roleId) async {
    final doc = await FirebaseFirestore.instance
        .collection('admin_ids')
        .doc(roleId)
        .get();
    if (!doc.exists) return false;
    return doc.data()?['isUsed'] == false;
  }

  // ✅ Check if role ID already used
  Future<bool> _isRoleIdUsed(String role, String roleId) async {
    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: role)
        .where('role_id', isEqualTo: roleId)
        .get();
    return userSnapshot.docs.isNotEmpty;
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRole == 'Select Role') {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please select a role")));
      return;
    }

    setState(() => _loading = true);

    final role = _selectedRole.toLowerCase();
    final roleId = _roleIdController.text.trim();

    if (role == 'admin') {
      final isValidAdmin = await _isAdminIdValid(roleId);
      if (!isValidAdmin) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Invalid or already used Admin ID")));
        return;
      }
    } else if (role == 'employee') {
      final employeeDoc = await FirebaseFirestore.instance
          .collection('employee_ids')
          .doc(roleId)
          .get();

      if (!employeeDoc.exists) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Invalid Employee ID")));
        return;
      }

      final employeeData = employeeDoc.data()!;
      if (employeeData['isUsed'] == true) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("This Employee ID has already been used")));
        return;
      }

      if (employeeData['name'].toString().toLowerCase() !=
          _nameController.text.trim().toLowerCase()) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Name does not match the assigned employee name")));
        return;
      }
    }

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final uid = credential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'role': role,
        'role_id': roleId,
      });

      // ✅ Mark the ID as used
      final idCollection = role == 'admin' ? 'admin_ids' : 'employee_ids';
      await FirebaseFirestore.instance
          .collection(idCollection)
          .doc(roleId)
          .update({'isUsed': true});

      setState(() => _loading = false);

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline,
                  size: 60, color: Color(0xFF388E3C)),
              SizedBox(height: 10),
              Text("Signup Successful!", style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
      );

      await Future.delayed(Duration(seconds: 2));
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => LoginScreen()));
    } on FirebaseAuthException catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Signup failed")));
    }
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
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(icon, color: Color(0xFF00C9A7)),
        labelText: label,
        border: OutlineInputBorder(),
        suffixIcon: toggleVisibility != null
            ? IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
          onPressed: toggleVisibility,
        )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Color(0xFF00C9A7),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            }
        ),
        title: Text("Sign Up", style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            width: size.width * 0.92,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(
                    controller: _nameController,
                    label: 'Name',
                    icon: Icons.person,
                    validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Enter name' : null,
                  ),
                  SizedBox(height: 15),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email,
                    validator: (val) =>
                    val != null && val.contains('@') ? null : 'Enter valid email',
                  ),
                  SizedBox(height: 15),
                  _buildTextField(
                    controller: _passwordController,
                    label: 'Password',
                    icon: Icons.lock,
                    obscure: _obscurePassword,
                    toggleVisibility: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    validator: _validatePassword,
                  ),
                  SizedBox(height: 15),
                  _buildTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    icon: Icons.lock_outline,
                    obscure: _obscurePassword,
                    toggleVisibility: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    validator: (val) => val != _passwordController.text
                        ? 'Passwords do not match'
                        : null,
                  ),
                  SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    items: roles.map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(role == 'Select Role' ? role : role[0].toUpperCase() + role.substring(1)),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedRole = val!),
                    decoration: InputDecoration(
                      labelText: "Role",
                      prefixIcon: Icon(Icons.group, color: Color(0xFF00C9A7)),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (val) =>
                    val == null || val == 'Select Role' ? 'Select a valid role' : null,
                  ),
                  SizedBox(height: 15),
                  _buildTextField(
                    controller: _roleIdController,
                    label: 'Role ID',
                    icon: Icons.badge,
                    validator: (val) =>
                    val == null || val.isEmpty ? 'Enter Role ID' : null,
                  ),
                  SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: _loading ? null : _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1976D2),
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _loading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text("Create Account", style: TextStyle(fontSize: 18, color: Colors.white,)),
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                    ),
                    child: Text("Already have an account? Login",
                        style: TextStyle(color: Color(0xFF1976D2))),
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
