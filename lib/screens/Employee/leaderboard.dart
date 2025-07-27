import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  int totalTasks = 0;
  int completedTasks = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPerformanceData();
  }

  Future<void> _loadPerformanceData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .where('assignedTo', isEqualTo: uid)
          .get();

      totalTasks = snapshot.docs.length;
      completedTasks =
          snapshot.docs.where((doc) => doc['status'] == 'completed').length;
    } catch (e) {
      debugPrint("❌ Error fetching leaderboard data: $e");
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final percent = totalTasks == 0 ? 0.0 : completedTasks / totalTasks;
    final pendingTasks = totalTasks - completedTasks;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Performance Overview"),
        backgroundColor: Colors.green.shade600, // ✅ Green AppBar
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: _buildExtendedPerformanceCard(theme, percent, pendingTasks),
      ),
    );
  }

  Widget _buildExtendedPerformanceCard(
      ThemeData theme, double percent, int pending) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
        child: Column(
          children: [
            Text(
              "Task Completion",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 30),
            CircularPercentIndicator(
              radius: 100,
              lineWidth: 14,
              animation: true,
              animationDuration: 1200,
              percent: percent.clamp(0, 1),
              center: Text(
                "${(percent * 100).toStringAsFixed(1)}%",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
              backgroundColor: theme.dividerColor.withOpacity(0.3),
              progressColor: theme.colorScheme.primary,
              circularStrokeCap: CircularStrokeCap.round,
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatBlock("Total Tasks", totalTasks, Icons.assignment_rounded, theme),
                _buildStatBlock("Completed", completedTasks, Icons.check_circle, theme),
                _buildStatBlock("Pending", pending, Icons.schedule, theme),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBlock(
      String title, int value, IconData icon, ThemeData theme) {
    return Column(
      children: [
        Icon(icon, size: 28, color: theme.colorScheme.onSurface.withOpacity(0.8)),
        const SizedBox(height: 8),
        Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
