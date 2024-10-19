import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register user with email, password, and profile image
  Future<String?> registerUser({
    required String name,
    required String email,
    required String password,
    required String profileImagePath,
  }) async {
    try {
      // Create user in Firebase Authentication
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        // Upload profile image to Firebase Storage
        String imageUrl = await _uploadProfileImage(user.uid, profileImagePath);

        // Save user data to Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'profileImageUrl': imageUrl,
          'role': 'user', // Set role to 'user'
          'uid': user.uid,
        });

        return null; // Registration successful
      } else {
        return 'User registration failed';
      }
    } on FirebaseAuthException catch (e) {
      return e.message; // Return error message
    } catch (e) {
      return e.toString(); // General error
    }
  }

  // Upload profile image to Firebase Storage and get the image URL
  Future<String> _uploadProfileImage(String uid, String imagePath) async {
    File imageFile = File(imagePath);

    try {
      // Define the storage path and upload the file
      Reference storageRef = _storage.ref().child('profileImages/$uid.jpg');
      await storageRef.putFile(imageFile);

      // Get the image URL after upload
      String imageUrl = await storageRef.getDownloadURL();
      return imageUrl;
    } catch (e) {
      throw Exception('Failed to upload profile image');
    }
  }

  // Login user with email and password
  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        // Retrieve user role from Firestore
        var userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          return userDoc.data()?['role']; // Return 'user' or 'admin'
        } else {
          return 'User role not found';
        }
      }
      return 'User login failed';
    } on FirebaseAuthException catch (e) {
      return e.message; // Return error message
    } catch (e) {
      return e.toString(); // General error
    }
  }

  // Method to log out the user
  Future<void> signOut() async {
    await _auth.signOut(); // Use _auth here
  }

  // Method to get the current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Method to update user profile information
  Future<String?> updateProfile({
    required String uid,
    required String username,
    String? email,
    String? profileImagePath,
    String? newPassword,
  }) async {
    try {
      // Check if user document exists
      var userDoc = await _firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) {
        return 'User document does not exist';
      }

      Map<String, dynamic> updatedData = {
        'name': username,
        'email': email,
      };

      // Upload new profile image if provided
      if (profileImagePath != null) {
        String profileImageUrl =
            await _uploadProfileImage(uid, profileImagePath);
        updatedData['profileImageUrl'] = profileImageUrl; // Update image URL
      }

      // Update user information in Firestore
      await _firestore.collection('users').doc(uid).update(updatedData);

      // Update password if provided
      if (newPassword != null && newPassword.isNotEmpty) {
        User? user = _auth.currentUser; // Get the current user
        if (user != null) {
          await user.updatePassword(newPassword); // Update password
        }
      }

      return null; // Update successful
    } catch (e) {
      print('Error updating profile: $e'); // Log the error
      return 'Error updating profile: $e';
    }
  }

  // Method to send password reset email
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // Password reset email sent
    } on FirebaseAuthException catch (e) {
      return e.message; // Return error message
    } catch (e) {
      return 'Error sending password reset email: $e'; // General error
    }
  }
}
