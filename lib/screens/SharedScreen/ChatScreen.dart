import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String taskId;
  final String otherUserName;

  const ChatScreen({
    super.key,
    required this.taskId,
    required this.otherUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? currentUid = FirebaseAuth.instance.currentUser?.uid;
  String? currentUserName;
  String? currentUserRole;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final userDoc = await _firestore.collection('users').doc(currentUid).get();
    final userData = userDoc.data();
    setState(() {
      currentUserName = userData?['name'] ?? 'User';
      currentUserRole = userData?['role']?.toString().toLowerCase();
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || currentUid == null || currentUserName == null || currentUserRole == null) return;

    await _firestore
        .collection('tasks')
        .doc(widget.taskId)
        .collection('messages')
        .add({
      'senderUid': currentUid,
      'senderName': currentUserName,
      'senderRole': currentUserRole,
      'message': text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 🌟 Determine AppBar color based on user role
    final appBarColor = currentUserRole == 'employee'
        ? Colors.green
        : currentUserRole == 'admin'
        ? Colors.blue
        : theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.person_outline),
            const SizedBox(width: 8),
            Text('Chat with ${widget.otherUserName}'),
          ],
        ),
        backgroundColor: appBarColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: theme.colorScheme.background,
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('tasks')
                    .doc(widget.taskId)
                    .collection('messages')
                    .orderBy('timestamp', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final messages = snapshot.data!.docs;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final data = messages[index].data() as Map<String, dynamic>;
                      final isMe = data['senderUid'] == currentUid;
                      final role = (data['senderRole'] ?? '').toString().toLowerCase();
                      final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
                      final formattedTime = timestamp != null
                          ? DateFormat('hh:mm a').format(timestamp)
                          : '';

                      // 💬 Bubble colors
                      final Color bubbleColor = role == 'admin'
                          ? Colors.blue
                          : Colors.green;

                      const textColor = Colors.white;

                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(12),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: bubbleColor,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(12),
                              topRight: const Radius.circular(12),
                              bottomLeft: Radius.circular(isMe ? 12 : 0),
                              bottomRight: Radius.circular(isMe ? 0 : 12),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(2, 2),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isMe)
                                Text(
                                  data['senderName'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: textColor,
                                  ),
                                ),
                              const SizedBox(height: 2),
                              Text(
                                data['message'] ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  formattedTime,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: textColor,
                                  ),
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
            ),
          ),
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: theme.colorScheme.surface,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: theme.textTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: TextStyle(color: theme.hintColor),
                      filled: true,
                      fillColor: theme.inputDecorationTheme.fillColor ??
                          theme.colorScheme.onSurface.withOpacity(0.05),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: appBarColor,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
