import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPerformancePage extends StatelessWidget {
  const AdminPerformancePage({super.key});

  Future<List<Map<String, dynamic>>> _fetchEmployeePerformance() async {
    final usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'employee')
        .get();

    List<Map<String, dynamic>> employeeData = [];

    for (var userDoc in usersSnapshot.docs) {
      String uid = userDoc.id;
      String name = userDoc['name'];

      final taskSnapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .where('assignedTo', isEqualTo: uid)
          .get();

      int totalTasks = taskSnapshot.docs.length;
      int completedTasks = taskSnapshot.docs
          .where((doc) => doc['status'].toString().toLowerCase() == 'completed')
          .length;

      double performance = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

      employeeData.add({
        'name': name,
        'totalTasks': totalTasks,
        'completedTasks': completedTasks,
        'performance': performance,
      });
    }

    employeeData.sort((a, b) => b['performance'].compareTo(a['performance']));
    return employeeData;
  }

  Color _getPerformanceColor(double performance) {
    double percent = performance * 100;
    if (percent <= 30) return Colors.red;
    if (percent <= 50) return Colors.orange;
    if (percent <= 80) return Colors.amber;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text(
          'Employee Performance',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder(
        future: _fetchEmployeePerformance(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
            return const Center(child: Text('No employee data found.'));
          }

          final employees = snapshot.data as List<Map<String, dynamic>>;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: employees.length,
            itemBuilder: (context, index) {
              final emp = employees[index];
              final name = emp['name'];
              final total = emp['totalTasks'];
              final completed = emp['completedTasks'];
              final performance = emp['performance'];
              final percent = (performance * 100).toStringAsFixed(1);
              final color = _getPerformanceColor(performance);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: isDark ? Colors.grey[850] : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: color.withOpacity(0.2),
                            child: Text(
                              name[0].toUpperCase(),
                              style: TextStyle(color: color),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Name: $name",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: textColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Performance: $percent%",
                        style: TextStyle(
                          color: subTextColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "Completed: $completed / $total",
                        style: TextStyle(
                          color: subTextColor,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: performance,
                          minHeight: 14,
                          backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
