import 'package:flutter/material.dart';
import '../../services/splash_screen_services.dart';
import 'side_bar.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  bool _isMenuOpen = false;
  String _selectedContent = 'Welcome to the Admin Dashboard';
  String? adminName;
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fetchAdminName();

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

  void _fetchAdminName() async {
    final name = await FirebaseUserService().getCurrentUserName();
    setState(() {
      adminName = name ?? 'Admin';
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
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Column(
                children: [
                  // App Bar (blue color)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blue, // fixed blue AppBar
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
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
                          'Admin Dashboard',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Main Content
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
                              color: Colors.black.withOpacity(0.1),
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
                              if (adminName != null)
                                Text(
                                  'Hello, $adminName!',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              const SizedBox(height: 16),
                              Text(
                                _selectedContent,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyLarge,
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

            // Dimming background if menu open
            if (_isMenuOpen)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _toggleMenu,
                  child: Container(color: Colors.black.withOpacity(0.4)),
                ),
              ),

            // Side menu
            SlideTransition(
              position: _slideAnimation,
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: SideMenu(
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
