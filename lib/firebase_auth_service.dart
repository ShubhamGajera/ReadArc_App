import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  // Method to register an admin with a profile picture
  Future<String?> registerAdmin({
    required String name,
    required String email,
    required String password,
    required String profileImagePath, // Profile picture path
  }) async {
    try {
      // Create user with email and password
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        // Upload profile picture to Firebase Storage
        String? profileImageUrl =
            await uploadProfileImage(user.uid, profileImagePath);

        // Add admin details and profile image URL to Firestore
        await _firestore.collection('Admins').doc(user.uid).set({
          'name': name,
          'email': email,
          'role': 'admin',
          'profileImageUrl': profileImageUrl, // Store profile picture URL
          'createdAt': Timestamp.now(),
        });

        return null; // Registration successful
      } else {
        return 'Admin registration failed';
      }
    } on FirebaseAuthException catch (e) {
      return e.message; // FirebaseAuth specific error
    } catch (e) {
      return 'An error occurred: $e'; // General error
    }
  }

  // Method to log in user and retrieve their role
  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      // Authenticate user using FirebaseAuth
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        // Retrieve user data from Firestore
        DocumentSnapshot<Map<String, dynamic>> userData = await _firestore
            .collection(
                'Admins') // Ensure this matches your Firestore structure
            .doc(user.uid)
            .get();

        if (userData.exists && userData.data() != null) {
          // Retrieve the role of the user (either 'admin' or 'user')
          return userData.data()!['role'] ??
              'user'; // default to 'user' if no role is found
        } else {
          return 'User role not found in Firestore';
        }
      } else {
        return 'Login failed';
      }
    } on FirebaseAuthException catch (e) {
      return e.message; // Return Firebase authentication error
    } catch (e) {
      return 'An error occurred: $e'; // Handle any other errors
    }
  }

  // Method to upload profile image
  Future<String?> uploadProfileImage(String uid, String imagePath) async {
    try {
      Reference storageReference =
          _firebaseStorage.ref().child('admin_profiles/$uid/profile.jpg');
      UploadTask uploadTask = storageReference.putFile(File(imagePath));

      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading profile image: $e');
      return null;
    }
  }

  // Method to log out the user
  Future<void> signOut() async {
    await _firebaseAuth.signOut(); // Use _firebaseAuth here
  }

  // Method to get the current user
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  // Method to update profile information
  Future<String?> updateProfile({
    required String uid,
    required String name,
    required String email,
    String? profileImagePath,
  }) async {
    try {
      Map<String, dynamic> updatedData = {
        'name': name,
        'email': email,
      };

      if (profileImagePath != null) {
        String? profileImageUrl =
            await uploadProfileImage(uid, profileImagePath);
        if (profileImageUrl != null) {
          updatedData['profileImageUrl'] = profileImageUrl; // Update image URL
        }
      }

      // Update user information in Firestore
      await _firestore.collection('Admins').doc(uid).update(updatedData);
      return null; // Update successful
    } catch (e) {
      return 'Error updating profile: $e';
    }
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // Return null if successful
    } on FirebaseAuthException catch (e) {
      return e.message; // Return the error message
    }
  }

  Future<String?> updatePassword(String newPassword) async {
    try {
      User? user = _auth.currentUser;
      await user!.updatePassword(newPassword);
      return null; // Return null if successful
    } on FirebaseAuthException catch (e) {
      return e.message; // Return the error message
    }
  }
}
