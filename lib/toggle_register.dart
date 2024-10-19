import 'package:flutter/material.dart';
import 'admin_register_page.dart'; // Ensure you import your AdminRegisterPage
import 'User/user_register_page.dart'; // Ensure you import your UserRegisterPage

class ToggleRegisterPage extends StatefulWidget {
  @override
  _ToggleRegisterPageState createState() => _ToggleRegisterPageState();
}

class _ToggleRegisterPageState extends State<ToggleRegisterPage> {
  bool _isAdminPage = true; // Track which page to show

  void _togglePage() {
    setState(() {
      _isAdminPage =
          !_isAdminPage; // Toggle between Admin and User Registration Pages
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isAdminPage ? const AdminRegisterPage() : const UserRegisterPage(),
      floatingActionButton: FloatingActionButton(
        onPressed: _togglePage,
        child: Icon(_isAdminPage ? Icons.person : Icons.admin_panel_settings),
      ),
    );
  }
}
