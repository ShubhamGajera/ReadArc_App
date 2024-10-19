import 'dart:io';
import 'dart:typed_data'; // For Uint8List
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads a file to Firebase Storage.
  Future<String?> uploadFile(
    dynamic file, // Can be File or Uint8List
    String filePath, {
    bool isWeb = false,
  }) async {
    try {
      final ref = _storage.ref().child(filePath);

      if (isWeb) {
        // Upload file for web
        final uploadTask = ref.putData(file as Uint8List);
        final snapshot = await uploadTask.whenComplete(() => {});
        final downloadUrl = await snapshot.ref.getDownloadURL();
        return downloadUrl;
      } else {
        // Upload file for mobile
        final uploadTask = ref.putFile(file as File);
        final snapshot = await uploadTask.whenComplete(() => {});
        final downloadUrl = await snapshot.ref.getDownloadURL();
        return downloadUrl;
      }
    } catch (e) {
      print('Error uploading file: $e');
      throw e;
    }
  }

  /// Method to upload a profile image for users.
  Future<String?> uploadProfileImage(File file) async {
    try {
      // Define the path where the profile image will be stored
      String filePath =
          'user_profiles/${file.path.split('/').last}'; // Adjust path as needed
      return await uploadFile(file, filePath);
    } catch (e) {
      print('Error uploading profile image: $e');
      return null;
    }
  }
}
