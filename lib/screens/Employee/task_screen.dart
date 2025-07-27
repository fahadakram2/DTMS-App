import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp_project1/services/employee_task_services.dart';
import '../SharedScreen/ChatScreen.dart';

class EmployeeTaskScreen extends StatefulWidget {
  const EmployeeTaskScreen({super.key});

  @override
  State<EmployeeTaskScreen> createState() => _EmployeeTaskScreenState();
}

class _EmployeeTaskScreenState extends State<EmployeeTaskScreen> {
  final EmployeeTaskService _taskService = EmployeeTaskService();
  final String? _employeeId = FirebaseAuth.instance.currentUser?.uid;
  String _searchQuery = '';

  Widget _buildTaskCard(DocumentSnapshot taskDoc) {
    final data = taskDoc.data()! as Map<String, dynamic>;
    final title = data['title'] ?? 'No Title';
    final description = data['description'] ?? '';
    final status = data['status'] ?? 'pending';
    final createdBy = data['createdByName'] ?? 'Admin';
    final dueDate = data['dueDate'] ?? 'N/A';
    final taskId = taskDoc.id;
    final lastViewed = data['lastViewedByEmployee'] as Timestamp?;

    if (_searchQuery.isNotEmpty &&
        !title.toLowerCase().contains(_searchQuery.toLowerCase()) &&
        !createdBy.toLowerCase().contains(_searchQuery.toLowerCase())) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tasks')
          .doc(taskId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, msgSnapshot) {
        bool showDot = false;

        if (msgSnapshot.hasData && msgSnapshot.data!.docs.isNotEmpty) {
          final message = msgSnapshot.data!.docs.first;
          final msgData = message.data() as Map<String, dynamic>;
          final Timestamp msgTime = msgData['timestamp'];
          final String senderUid = msgData['senderUid'];

          if (senderUid != _employeeId &&
              (lastViewed == null || msgTime.toDate().isAfter(lastViewed.toDate()))) {
            showDot = true;
          }
        }

        final theme = Theme.of(context);

        return Card(
          elevation: 8,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: theme.cardColor,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              collapsedBackgroundColor: theme.cardColor,
              backgroundColor: theme.colorScheme.surface,
              leading: CircleAvatar(
                backgroundColor: status == 'completed' ? Colors.green : Colors.orange,
                child: const Icon(Icons.task, color: Colors.white),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (showDot)
                    const Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: Icon(Icons.circle, color: Colors.red, size: 10),
                    ),
                ],
              ),
              subtitle: Text(
                "Status: $status",
                style: TextStyle(
                  color: status == 'completed' ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: theme.colorScheme.surface,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(Icons.info_outline, color: theme.colorScheme.primary),
                        const SizedBox(width: 6),
                        Text("Task Details", style: theme.textTheme.titleSmall),
                      ]),
                      const SizedBox(height: 6),
                      Text('📝 Description: $description'),
                      Text('📅 Due Date: $dueDate'),
                      Text('👨‍💼 Assigned By: $createdBy'),
                      const SizedBox(height: 14),
                      if (status != 'completed')
                        ElevatedButton.icon(
                          onPressed: () async {
                            await _taskService.markTaskAsCompleted(taskId);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Task marked as completed')),
                            );
                          },
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Mark Completed'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('tasks')
                              .doc(taskId)
                              .update({'lastViewedByEmployee': FieldValue.serverTimestamp()});

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                taskId: taskId,
                                otherUserName: createdBy,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.message_outlined),
                        label: const Text('Message Admin'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_employeeId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        backgroundColor: Colors.green,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by title or admin name',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
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
              stream: _taskService.getTasksForEmployee(_employeeId!),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final tasks = snapshot.data?.docs ?? [];

                if (tasks.isEmpty) {
                  return const Center(child: Text('No tasks assigned yet.'));
                }

                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return _buildTaskCard(tasks[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
