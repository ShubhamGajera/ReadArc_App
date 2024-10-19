import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'firebase_auth_service.dart'; // Ensure this imports your auth service
import 'firebase_storage_service.dart'; // Ensure this imports your Firebase storage service

class UpdateProfilePage extends StatefulWidget {
  @override
  _UpdateProfilePageState createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final _formKey = GlobalKey<FormState>();
  String? _username;
  String? _email;
  String? _profileImageUrl;
  File? _imageFile;
  String? _newPassword; // For storing the new password
  bool _isChangingPassword = false; // To toggle password change field

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data when the page is initialized
  }

  Future<void> _loadUserData() async {
    final user = AuthService().getCurrentUser();

    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> userData = await FirebaseFirestore
          .instance
          .collection('Admins')
          .doc(user.uid)
          .get();

      if (userData.exists && userData.data() != null) {
        setState(() {
          _username = userData.data()!['name'];
          _email = userData.data()!['email'];
          _profileImageUrl = userData.data()!['profileImageUrl'];
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        // Upload the new profile image if it exists
        String? newProfileImageUrl;
        if (_imageFile != null) {
          newProfileImageUrl =
              await FirebaseStorageService().uploadProfileImage(_imageFile!);
        }

        // Update Firestore with new data
        final user = AuthService().getCurrentUser();
        await FirebaseFirestore.instance
            .collection('Admins')
            .doc(user!.uid)
            .update({
          'name': _username,
          'profileImageUrl': newProfileImageUrl ?? _profileImageUrl,
        });

        // Update password if checkbox is selected and a new password is provided
        if (_isChangingPassword &&
            _newPassword != null &&
            _newPassword!.isNotEmpty) {
          await user
              .updatePassword(_newPassword!); // Update the user's password
        }

        Navigator.pop(context); // Go back to the profile page after updating
      } catch (e) {
        // Handle any errors (e.g., show a message)
        print('Error updating profile: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Profile'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : (_profileImageUrl != null
                          ? NetworkImage(_profileImageUrl!)
                          : AssetImage('assets/ReadArc.png') as ImageProvider),
                  child: _imageFile == null
                      ? const Icon(Icons.camera_alt, size: 30)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _username,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
                onSaved: (value) {
                  _username = value;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _email,
                decoration: const InputDecoration(labelText: 'Email'),
                enabled: false, // Prevent editing the email
              ),
              const SizedBox(height: 16),
              // Checkbox for changing password
              Row(
                children: [
                  Checkbox(
                    value: _isChangingPassword,
                    onChanged: (value) {
                      setState(() {
                        _isChangingPassword = value ?? false;
                      });
                    },
                  ),
                  const Text('Change Password'),
                ],
              ),
              if (_isChangingPassword) ...[
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'New Password'),
                  obscureText: true,
                  onSaved: (value) {
                    _newPassword = value; // Save new password
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a new password';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _updateProfile,
                child: const Text('Update Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
