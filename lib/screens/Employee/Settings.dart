import 'package:fyp_project1/screens/Employee/profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fyp_project1/services/setting_services.dart';
import 'package:fyp_project1/screens/SharedScreen/theme_provider.dart';
import 'profile.dart'; // ✅ Import AdminProfile

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDark = false;
  final SettingService _settingService = SettingService();

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    bool isDark = await _settingService.loadThemePreference();
    setState(() => _isDark = isDark);
  }

  Future<void> _toggleTheme(bool value) async {
    setState(() => _isDark = value);
    await _settingService.saveThemePreference(value);
    context.read<ThemeProvider>().toggleTheme(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 🌙 Theme toggle
          SwitchListTile(
            title: const Text("Dark Mode"),
            value: _isDark,
            onChanged: _toggleTheme,
            secondary: const Icon(Icons.dark_mode),
          ),

          const Divider(),

          // 👤 Edit Profile
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text("Edit Profile"),
            subtitle: const Text("Update your name and photo"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EmployeeProfile()),
              );
            },
          ),

          const Divider(),

          // ℹ️ About DTMS
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("About DTMS"),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: "DTMS",
                applicationVersion: "1.0.0",
                applicationLegalese: "© 2025 DTMS",
              );
            },
          ),

          const Divider(),

          // 📊 New Section: System Usage Info
          ListTile(
            leading: const Icon(Icons.system_update_alt),
            title: const Text("System Usage Info"),
            subtitle: const Text("App Version: 1.0.0\nLast Updated: July 2025"),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
