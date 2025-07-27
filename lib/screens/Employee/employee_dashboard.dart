import 'package:flutter/material.dart';
import '../../services/splash_screen_services.dart';
import 'side_bar.dart';

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> with SingleTickerProviderStateMixin {
  bool _isMenuOpen = false;
  String _selectedContent = 'Welcome to the Employee Dashboard';
  String? employeeName;
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fetchEmployeeName();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _fetchEmployeeName() async {
    final name = await FirebaseUserService().getCurrentUserName();
    setState(() {
      employeeName = name ?? 'Employee';
    });
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _onMenuItemSelected(String content) {
    setState(() {
      _selectedContent = content;
    });
    _toggleMenu();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Column(
                children: [
                  // AppBar section with green color
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.green, // 👈 Green AppBar
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white),
                          onPressed: _toggleMenu,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Employee Dashboard',
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Main card content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(15),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (employeeName != null)
                                Text(
                                  'Hello, $employeeName!',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: theme.textTheme.bodyLarge?.color,
                                  ),
                                ),
                              const SizedBox(height: 16),
                              Text(
                                _selectedContent,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: theme.textTheme.bodyMedium?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Side menu
            SlideTransition(
              position: _slideAnimation,
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: MediaQuery.of(context).size.height,
                  child: SideMenuEmployee(
                    onItemSelected: _onMenuItemSelected,
                    onClose: _toggleMenu,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
