import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readarc_admin_apk/User/user_authservice.dart';
import '../theme_provider.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  int _selectedIndex = 1;
  String? _username;
  String? _email;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data when the page is initialized
  }

  Future<void> _loadUserData() async {
    final user = await AuthService().getCurrentUser();

    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> userData =
          await FirebaseFirestore.instance
              .collection('users') // Change this to your user collection
              .doc(user.uid)
              .get();

      if (userData.exists && userData.data() != null) {
        setState(() {
          _username = userData.data()!['name'];
          _email = userData.data()!['email'];
          _profileImageUrl = userData.data()!['profileImageUrl'];
        });
      } else {
        print('User data not found in Firestore');
      }
    } else {
      print('No user is currently logged in');
    }
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(
            context, '/user-home'); // Change to user home
        break;
      case 1:
        // Stay on the profile page
        break;
    }
  }

  Future<void> _logout() async {
    await AuthService().signOut();
    Navigator.pushReplacementNamed(
        context, '/admin-welcome'); // Change to user welcome
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final themeProvider =
        Provider.of<ThemeProvider>(context); // Access the theme provider

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Section
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: themeProvider.isDarkMode
                        ? Colors.grey.shade800
                        : Colors.grey.shade400,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: screenWidth * 0.25,
                    backgroundImage: _profileImageUrl != null
                        ? NetworkImage(_profileImageUrl!)
                        : const AssetImage('assets/ReadArc.png')
                            as ImageProvider,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _username ?? 'User',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _email ?? 'user@example.com',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context,
                          '/user-edit-profile'); // Change to user edit profile
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue, // Change back to blue
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    child: const Text('Edit Profile'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Settings and Options Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.dark_mode),
                    title: const Text('Dark Mode'),
                    trailing: Switch(
                      value:
                          themeProvider.isDarkMode, // Get current theme state
                      onChanged: (value) {
                        themeProvider.toggleTheme(); // Toggle the theme
                      },
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Library'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.bookmark),
                    title: const Text('Bookmarks'),
                    onTap: () {
                      Navigator.pushNamed(context,
                          '/user-bookmarks'); // Navigate to bookmarks page
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.download),
                    title: const Text('Downloads'),
                    onTap: () {
                      Navigator.pushNamed(context,
                          '/user-downloads'); // Navigate to downloads page
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('About Us'),
                    onTap: () {
                      Navigator.pushNamed(context, '/about-us');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Log Out'),
                    onTap: _logout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
