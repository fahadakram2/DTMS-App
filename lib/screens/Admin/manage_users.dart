import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageUserScreen extends StatefulWidget {
  const ManageUserScreen({super.key});

  @override
  State<ManageUserScreen> createState() => _ManageUserScreenState();
}

class _ManageUserScreenState extends State<ManageUserScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = '';

  void _showAddEmployeeDialog() {
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _idController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Add New Employee', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Employee Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _idController,
                decoration: InputDecoration(
                  labelText: 'Employee ID',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.badge),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Employee'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                    onPressed: () async {
                      final name = _nameController.text.trim();
                      final id = _idController.text.trim();
                      if (name.isEmpty || id.isEmpty) return;

                      // Add user to 'users' collection
                      await _firestore.collection('users').add({
                        'name': name,
                        'role_id': id,
                        'role': 'employee',
                      });

                      // Add corresponding entry to 'employee_ids' collection
                      await _firestore.collection('employee_ids').doc(id).set({
                        'isUsed': false,
                        'name': name,
                      });

                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Employee added successfully')),
                      );
                    }

                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteEmployee(DocumentSnapshot employeeDoc) {
    final employeeData = employeeDoc.data() as Map<String, dynamic>;
    final storedRoleId = employeeData['role_id'];
    final TextEditingController _confirmIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Delete Employee', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('Enter the employee ID to confirm deletion'),
              const SizedBox(height: 12),
              TextField(
                controller: _confirmIdController,
                decoration: InputDecoration(
                  labelText: 'Employee ID',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () async {
                      final enteredId = _confirmIdController.text.trim();
                      if (enteredId == storedRoleId) {
                        await _firestore.collection('users').doc(employeeDoc.id).delete();
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Employee deleted')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Invalid Employee ID')),
                        );
                      }
                    },
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeeCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final name = data['name'] ?? 'Unnamed';
    final roleId = data['role_id'] ?? 'Unknown';

    if (_searchQuery.isNotEmpty &&
        !name.toLowerCase().contains(_searchQuery.toLowerCase()) &&
        !roleId.toLowerCase().contains(_searchQuery.toLowerCase())) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blueAccent,
          child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?'),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Employee ID: $roleId'),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _confirmDeleteEmployee(doc),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Employees'),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Add Employee',
            onPressed: _showAddEmployeeDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by Name or Employee ID',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .where('role', isEqualTo: 'employee')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final employees = snapshot.data?.docs ?? [];
                if (employees.isEmpty) {
                  return const Center(child: Text('No employees found.'));
                }

                return ListView.builder(
                  itemCount: employees.length,
                  itemBuilder: (context, index) => _buildEmployeeCard(employees[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
