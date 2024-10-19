import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Add provider package
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:readarc_admin_apk/Add_Book_Page.dart';
import 'package:readarc_admin_apk/Admin_Welcom_page.dart';
import 'package:readarc_admin_apk/Admin_home_page.dart';
import 'package:readarc_admin_apk/Admin_login_page.dart';
import 'package:readarc_admin_apk/Admin_register_page.dart';
import 'package:readarc_admin_apk/User/book_search.dart';
import 'package:readarc_admin_apk/User/home_page.dart';
import 'package:readarc_admin_apk/User/user_edit_profile.dart';
import 'package:readarc_admin_apk/User/user_login.dart';
import 'package:readarc_admin_apk/User/user_profile_page.dart';
import 'package:readarc_admin_apk/User/user_register_page.dart';
import 'package:readarc_admin_apk/aboutus_page.dart';
import 'package:readarc_admin_apk/admin_edit_profile_page.dart';
import 'package:readarc_admin_apk/admin_profile_page.dart';
import 'package:readarc_admin_apk/book_edit_page.dart';
import 'package:readarc_admin_apk/feedback_recive.dart'; //
import 'package:readarc_admin_apk/theme_provider.dart'; // Import ThemeProvider
import 'package:readarc_admin_apk/toggle_login.dart';
import 'package:readarc_admin_apk/toggle_register.dart';
import 'Forget_Password/forgetpassword_page.dart';
import 'User/book_page.dart';
import 'User/bookmark_page.dart';
import 'User/dowenload_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ReadArc Admin',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        appBarTheme: AppBarTheme(
          color: Colors.blue,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        appBarTheme: AppBarTheme(
          color: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      themeMode: themeProvider.isDarkMode
          ? ThemeMode.dark
          : ThemeMode.light, // Use the current theme
      home: FutureBuilder<User?>(
        future: _checkUserLoggedIn(), // Check if user is logged in
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show loading indicator while checking user state
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data != null) {
            // User is logged in, check the user role
            return FutureBuilder<String?>(
              future: _getUserRole(snapshot.data!.uid),
              builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (roleSnapshot.hasData && roleSnapshot.data != null) {
                  if (roleSnapshot.data == 'admin') {
                    return AdminHomePage(); // Navigate to admin home
                  } else {
                    return UserHomePage(); // Navigate to user home
                  }
                }
                return AdminWelcomePage(); // Default page if no role is found
              },
            );
          }
          // User is not logged in, show welcome page
          return AdminWelcomePage();
        },
      ),
      routes: {
        '/admin-login': (context) => AdminLoginPage(),
        '/admin-register': (context) => AdminRegisterPage(),
        '/user-login': (context) => UserLoginPage(),
        '/user-register': (context) => UserRegisterPage(),
        '/toggle-register': (context) => ToggleRegisterPage(),
        '/toggle-login': (context) => ToggleLoginPage(),
        '/admin-home': (context) => AdminHomePage(),
        '/user-home': (context) => UserHomePage(),
        '/add-book': (context) => AddBookPage(),
        '/admin-profile': (context) => AdminProfilePage(),
        '/user-profile': (context) => UserProfilePage(),
        '/admin-edit-profile': (context) => UpdateProfilePage(),
        '/user-edit-profile': (context) => UpdateUserProfilePage(),
        '/about-us': (context) => AboutUsPage(),
        '/admin-welcome': (context) => AdminWelcomePage(),
        '/forgot_password': (context) => ForgotPasswordPage(),
        '/book-details': (context) => BookPage(),
        '/user-bookmarks': (context) => BookmarksPage(),
        '/user-downloads': (context) => DownloadsPage(),
        '/search': (context) => SearchPage(),
        '/feedback-management': (context) => FeedbackManagementPage(),
      },
    );
  }

  // Function to check if user is logged in
  Future<User?> _checkUserLoggedIn() async {
    final user = FirebaseAuth.instance.currentUser;
    return user; // Return the current user or null if not logged in
  }

  // Function to get the user role from Firestore
  Future<String?> _getUserRole(String uid) async {
    try {
      var userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return userDoc.data()?['role'];
      }
    } catch (e) {
      print('Error fetching user role: $e');
    }
    return null; // Return null if role is not found
  }
}
