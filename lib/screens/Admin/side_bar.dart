import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'profile.dart';
import '../SharedScreen/logout.dart';
import 'Settings.dart';
import 'add_task.dart';
import 'manage_users.dart';
import 'show_task.dart';
import 'leaderboard.dart';

class SideMenu extends StatelessWidget {
  final String currentAdminUid = FirebaseAuth.instance.currentUser!.uid;
  final Function(String) onItemSelected;
  final VoidCallback onClose;

  SideMenu({
    super.key,
    required this.onItemSelected,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      elevation: 8,
      color: theme.colorScheme.surface,
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.blue),
                    onPressed: onClose,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Menu',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: isDark ? Colors.grey[700] : Colors.grey[300]),

            _buildMenuItem(Icons.person, 'Profile', context),
            _buildMenuItem(Icons.group_add, 'Manage User', context),
            _buildMenuItem(Icons.add_task, 'Add Task', context),
            _buildMenuItem(Icons.task, 'Show Task', context),
            _buildMenuItem(Icons.notifications, 'Leaderboard', context),
            _buildMenuItem(Icons.settings, 'Settings', context),

            const Spacer(),

            InkWell(
              onTap: () => handleLogout(context),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.redAccent),
                    SizedBox(width: 10),
                    Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, BuildContext context) {
    return InkWell(
      onTap: () {
        if (title == 'Profile') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => AdminProfile()));
        } else if (title == 'Settings') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
        } else if (title == 'Add Task') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateTaskScreen()));
        } else if (title == 'Show Task') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ShowTaskScreen(adminId: currentAdminUid)));
        } else if (title == 'Manage User') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageUserScreen()));
        } else if(title == 'Leaderboard') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => AdminPerformancePage()));
        }
        else {
          onItemSelected(title);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: Colors.blue),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
