import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:readarc_admin_apk/User/book_read.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart'; // Make sure to add this dependency for downloading files
import 'package:path_provider/path_provider.dart'; // For getting the download directory
import 'package:readarc_admin_apk/feedback_recive.dart'; // Import the feedback management page

import 'dart:io';

import 'package:readarc_admin_apk/User/feedback.dart';

class BookPage extends StatefulWidget {
  @override
  _BookPageState createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  bool _isBookmarked = false; // Track bookmark state
  bool _isDownloading = false; // Track download state
  String? _downloadPath; // Path to the downloaded file

  @override
  Widget build(BuildContext context) {
    final bookSnapshot = ModalRoute.of(context)!.settings.arguments;

    if (bookSnapshot is! DocumentSnapshot) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('Invalid book data!'),
        ),
      );
    }

    final Map<String, dynamic> book =
        bookSnapshot.data() as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text(book['name']),
        actions: [
          IconButton(
              icon: const Icon(Icons.feedback),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FeedbackPage(bookId: book['id']),
                  ),
                );
              }),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Full Book Image
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(book['image_url']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Book Details
            Text(
              book['name'],
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Author: ${book['author']}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Genre: ${book['genre']}', // Genre added
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Description:\n${book['description']}', // Description label added
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    if (!_isDownloading) {
                      setState(() {
                        _isDownloading = true; // Update the downloading state
                      });
                      await downloadBook(book['pdf_url'], book['name']);
                      setState(() {
                        _isDownloading = false; // Reset the downloading state
                        _downloadPath =
                            '${book['name']}.pdf'; // Set the downloaded file name
                      });
                    }
                  },
                  icon: _isDownloading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : const Icon(Icons.download),
                  label: const Text('Download'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    await toggleBookmark(book);
                  },
                  icon: Icon(
                    _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  ),
                  label: Text(_isBookmarked ? 'Bookmarked' : 'Bookmark'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to BookRead page to read PDF
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookRead(pdfUrl: book['pdf_url']),
                    ),
                  );
                },
                child: const Text('Read'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> downloadBook(String url, String bookName) async {
    // Request storage permissions
    var permissionStatus = await Permission.storage.request();

    if (permissionStatus.isGranted) {
      try {
        final dir = await getApplicationDocumentsDirectory();
        final path = '${dir.path}/$bookName.pdf';

        await Dio().download(url, path);

        // Show a success message
        print('Download completed: $path');
      } catch (e) {
        // Handle error
        print('Download error: $e');
      }
    } else {
      // Handle case when permission is denied
      print('Permission denied. Unable to download file.');
      // Optionally show a dialog to inform the user
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Permission Denied'),
          content:
              const Text('Please grant storage permission to download files.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> toggleBookmark(Map<String, dynamic> book) async {
    // Implement bookmark functionality
    final userId = 'YOUR_USER_ID'; // Replace with the current user's ID

    final bookmarksRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('bookmarks');
    final doc = await bookmarksRef.doc(book['id']).get();

    if (doc.exists) {
      // Remove from bookmarks
      await bookmarksRef.doc(book['id']).delete();
      setState(() {
        _isBookmarked = false; // Update bookmark state
      });
      print('Bookmark removed');
    } else {
      // Add to bookmarks
      await bookmarksRef.doc(book['id']).set(book);
      setState(() {
        _isBookmarked = true; // Update bookmark state
      });
      print('Bookmark added');
    }
  }
}
