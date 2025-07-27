import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class EmployeeProfile extends StatefulWidget {
  @override
  _EmployeeProfileState createState() => _EmployeeProfileState();
}

class _EmployeeProfileState extends State<EmployeeProfile> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _employeeIdController = TextEditingController();

 // String employeeId = '';
  String role = '';
  File? _imageFile;

  bool _editing = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEmployeeData();
  }

  Future<void> _loadEmployeeData() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      final data = userDoc.data();
      if (data != null) {
        _nameController.text = data['name'] ?? '';
        _emailController.text = data['email'] ?? '';
        role = data['role'] ?? '';
        _employeeIdController.text = data['emp_id'] ?? '';
      }
    }
    setState(() => _loading = false);
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _saveChanges() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      // Update Firestore
      await _firestore.collection('users').doc(uid).update({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Employee Profile"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(_editing ? Icons.save : Icons.edit),
            onPressed: _editing ? _saveChanges : () => setState(() => _editing = true),
          )
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                _imageFile != null ? FileImage(_imageFile!) : null,
                child: _imageFile == null
                    ? Icon(Icons.person, size: 50)
                    : null,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Name"),
              enabled: _editing,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
              enabled: _editing,
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(labelText: "Role"),
              readOnly: true,
              controller: TextEditingController(text: role),
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(labelText: "Employee ID"),
              readOnly: true,
              controller: _employeeIdController,
            ),
          ],
        ),
      ),
    );
  }

}
