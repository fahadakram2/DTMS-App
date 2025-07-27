import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp_project1/services/admin_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dueDateController = TextEditingController();
  final AdminTaskService _taskService = AdminTaskService();

  bool _isLoading = false;
  List<Map<String, dynamic>> _employees = [];
  List<Map<String, dynamic>> _selectedEmployees = [];

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'employee') // Capital E
        .get();

    final employees = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'uid': doc.id,
        'name': data['name'] ?? 'Unnamed',
      };
    }).toList();

    setState(() => _employees = employees);
  }

  Future<void> _selectDueDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      _dueDateController.text = pickedDate.toIso8601String().split("T").first;
    }
  }

  Future<void> _submitTask() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedEmployees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one employee')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception('No admin user found');

      for (var emp in _selectedEmployees) {
        await _taskService.createTask(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          dueDate: _dueDateController.text.trim(),
          assignedToUid: emp['uid'],
          createdByUid: currentUser.uid,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task created successfully')),
      );

      _formKey.currentState?.reset();
      _dueDateController.clear();
      setState(() => _selectedEmployees = []);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }

    setState(() => _isLoading = false);
  }

  // Helper to remove selected employee on chip close icon tap
  void _removeSelectedEmployee(Map<String, dynamic> emp) {
    setState(() {
      _selectedEmployees.removeWhere((element) => element['uid'] == emp['uid']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Task'),
        backgroundColor: Colors.blue,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Task Title", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'Enter task title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Title required' : null,
                ),
                const SizedBox(height: 16),

                const Text("Description", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    hintText: 'Enter task details',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (val) => val == null || val.isEmpty ? 'Description required' : null,
                ),
                const SizedBox(height: 16),

                const Text("Due Date", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _dueDateController,
                  readOnly: true,
                  onTap: _selectDueDate,
                  decoration: const InputDecoration(
                    hintText: 'Select due date',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Select a due date' : null,
                ),
                const SizedBox(height: 16),

                const Text("Assign To", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                MultiSelectDialogField<Map<String, dynamic>>(
                  items: _employees
                      .map((emp) => MultiSelectItem(emp, emp['name']))
                      .toList(),
                  listType: MultiSelectListType.LIST,
                  searchable: true,
                  title: const Text("Select Employee(s)"),
                  buttonText: const Text("Assign Employee(s)"),
                  onConfirm: (values) => setState(() => _selectedEmployees = values),
                  chipDisplay: MultiSelectChipDisplay(
                    chipColor: Colors.green.shade200,
                    textStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                    icon: const Icon(Icons.close, size: 18, color: Colors.black),
                    onTap: (item) {
                      _removeSelectedEmployee(item);
                    },
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade800,
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.blue.shade800,
            padding: const EdgeInsets.symmetric(vertical: 14),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          onPressed: _isLoading ? null : _submitTask,
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.blue)
              : const Text('Create Task'),
        ),
      ),
    );
  }
}
