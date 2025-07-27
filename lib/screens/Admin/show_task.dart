import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp_project1/services/admin_services.dart';
import 'package:fyp_project1/screens/SharedScreen/ChatScreen.dart';

class ShowTaskScreen extends StatefulWidget {
  final String adminId;

  const ShowTaskScreen({Key? key, required this.adminId}) : super(key: key);

  @override
  State<ShowTaskScreen> createState() => _ShowTaskScreenState();
}

class _ShowTaskScreenState extends State<ShowTaskScreen> {
  final FirebaseTaskService _taskService = FirebaseTaskService();
  String _searchQuery = '';

  Future<String> _getEmployeeName(String employeeId) async {
    return await _taskService.getEmployeeName(employeeId);
  }

  void _confirmDelete(String taskId) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning, color: Colors.red, size: 50),
              const SizedBox(height: 16),
              const Text('Delete Task?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text(
                'Are you sure you want to delete this task? This action cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancel'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.of(ctx).pop();
                      await _taskService.deleteTask(taskId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Task deleted successfully')),
                      );
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard(DocumentSnapshot taskDoc) {
    final data = taskDoc.data()! as Map<String, dynamic>;
    final title = data['title'] ?? 'No Title';
    final status = data['status'] ?? 'Unknown';
    final assignedTo = data['assignedTo'] ?? '';
    final taskId = taskDoc.id;
    final Timestamp? lastViewed = data['lastViewedByAdmin'];

    return FutureBuilder<String>(
      future: _getEmployeeName(assignedTo),
      builder: (context, snapshot) {
        final employeeName = snapshot.data ?? 'Loading...';

        if (_searchQuery.isNotEmpty &&
            !title.toLowerCase().contains(_searchQuery.toLowerCase()) &&
            !employeeName.toLowerCase().contains(_searchQuery.toLowerCase())) {
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

              if (senderUid == assignedTo &&
                  (lastViewed == null || msgTime.toDate().isAfter(lastViewed.toDate()))) {
                showDot = true;
              }
            }

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Employee: $employeeName'),
                            Text(
                              'Status: $status',
                              style: TextStyle(
                                color: status == 'completed' ? Colors.green : Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        if (status != 'completed')
                          Stack(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chat_bubble_outline, color: Colors.blue),
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection('tasks')
                                      .doc(taskId)
                                      .update({'lastViewedByAdmin': FieldValue.serverTimestamp()});
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChatScreen(
                                        taskId: taskId,
                                        otherUserName: employeeName,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              if (showDot)
                                Positioned(
                                  right: 6,
                                  top: 6,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(taskId),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assigned Tasks'),
        backgroundColor: Colors.blue,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search by task title or employee name',
                  prefixIcon: const Icon(Icons.search),
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
                stream: _taskService.getTasksByAdminId(widget.adminId),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final tasks = snapshot.data?.docs ?? [];

                  if (tasks.isEmpty) {
                    return const Center(child: Text('No tasks assigned.'));
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
      ),
    );
  }
}
