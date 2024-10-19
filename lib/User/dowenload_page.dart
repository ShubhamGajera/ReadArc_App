import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';

Future<void> requestStoragePermission() async {
  var status = await Permission.storage.status;

  if (status.isDenied) {
    // Request permission if it is denied
    status = await Permission.storage.request();
  }

  if (status.isGranted) {
    print("Storage permission granted.");
  } else {
    print("Storage permission denied.");
  }
}

class DownloadsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
      ),
      body: FutureBuilder<List<FileSystemEntity>>(
        future: _getDownloads(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading downloads'));
          }

          final downloads = snapshot.data!;

          if (downloads.isEmpty) {
            return const Center(child: Text('No downloads yet.'));
          }

          return ListView.builder(
            itemCount: downloads.length,
            itemBuilder: (context, index) {
              final file = downloads[index];

              return ListTile(
                title: Text(file.path.split('/').last),
                onTap: () {
                  // Open the PDF reader or handle the file
                  print('Opening: ${file.path}');
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Example usage of downloadBook
          downloadBook(
            context,
            'https://example.com/path/to/book.pdf', // Replace with your PDF URL
            'MyBook', // Replace with your desired book name
          );
        },
        child: const Icon(Icons.download),
      ),
    );
  }

  Future<List<FileSystemEntity>> _getDownloads() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir
        .listSync()
        .where((entity) => entity.path.endsWith('.pdf'))
        .toList();
  }

  Future<void> downloadBook(
      BuildContext context, String url, String bookName) async {
    await requestStoragePermission(); // Ensure permission is requested

    var permissionStatus = await Permission.storage.status;

    if (permissionStatus.isGranted) {
      try {
        final dir = await getApplicationDocumentsDirectory();
        final path = '${dir.path}/$bookName.pdf';

        await Dio().download(url, path);

        // Show a success message
        print('Download completed: $path');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download completed!')),
        );
      } catch (e) {
        // Handle error
        print('Download error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download error: $e')),
        );
      }
    } else {
      // Handle case when permission is denied
      print('Permission denied. Unable to download file.');
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
}
