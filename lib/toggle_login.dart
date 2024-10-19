import 'package:flutter/material.dart';
import 'admin_login_page.dart'; // Ensure you import your AdminLoginPage
import 'User/user_login.dart'; // Ensure you import your UserLoginPage

class ToggleLoginPage extends StatefulWidget {
  @override
  _ToggleLoginPageState createState() => _ToggleLoginPageState();
}

class _ToggleLoginPageState extends State<ToggleLoginPage> {
  bool _isAdminPage = true; // Track which page to show

  void _togglePage() {
    setState(() {
      _isAdminPage = !_isAdminPage; // Toggle between Admin and User Login Pages
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isAdminPage ? const AdminLoginPage() : const UserLoginPage(),
      floatingActionButton: FloatingActionButton(
        onPressed: _togglePage,
        child: Icon(_isAdminPage ? Icons.person : Icons.admin_panel_settings),
      ),
    );
  }
}
