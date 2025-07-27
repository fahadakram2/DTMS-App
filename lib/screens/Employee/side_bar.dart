import 'package:fyp_project1/screens/Employee/leaderboard.dart';
import 'package:fyp_project1/screens/Employee/notifications.dart';
import 'package:fyp_project1/screens/Employee/task_screen.dart';
import 'package:flutter/material.dart';
import '../SharedScreen/logout.dart';
import 'Settings.dart';
import 'profile.dart';

class SideMenuEmployee extends StatelessWidget {
  final Function(String) onItemSelected;
  final VoidCallback onClose;

  const SideMenuEmployee({
    super.key,
    required this.onItemSelected,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      elevation: 8,
      color: theme.colorScheme.surface,
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(16),
        bottomRight: Radius.circular(16),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar with close button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 20),
                    onPressed: onClose,
                  ),
                  const Text(
                    'Menu',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const Divider(),

            // Menu Items
            _buildMenuItem(context, Icons.person, 'Profile'),
            _buildMenuItem(context, Icons.task_alt, 'Check Task'),
            //_buildMenuItem(context, Icons.notifications, 'Notifications'),
            _buildMenuItem(context, Icons.leaderboard, 'Leaderboard'),
            _buildMenuItem(context, Icons.settings, 'Settings'),

            const Spacer(),

            // Logout
            InkWell(
              onTap: () => handleLogout(context),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 10),
                    Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.red,
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

  Widget _buildMenuItem(BuildContext context, IconData icon, String title) {
    return InkWell(
      onTap: () {
        if (title == 'Profile') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => EmployeeProfile()));
        } else if (title == 'Check Task') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const EmployeeTaskScreen()));
        } else if (title == 'Settings') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
        } else if (title == 'Leaderboard'){
          Navigator.push(context, MaterialPageRoute(builder: (_) => LeaderboardScreen()));
        }/*else if (title == 'Notifications'){
          Navigator.push(context, MaterialPageRoute(builder: (_) => EmployeeNotificationScreen()));
        }*/
        else {
          onItemSelected(title);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: Colors.green),
            const SizedBox(width: 12),
            const SizedBox(width: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 16, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
