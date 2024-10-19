import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookRead extends StatefulWidget {
  final String pdfUrl;

  const BookRead({Key? key, required this.pdfUrl}) : super(key: key);

  @override
  _BookReadState createState() => _BookReadState();
}

class _BookReadState extends State<BookRead> {
  String? _localPath;
  bool _isDarkMode = false;
  bool _isLoading = true; // State to track loading
  late PdfController _pdfController;
  int _currentPage = 0;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _downloadAndLoadPDF();
  }

  Future<void> _downloadAndLoadPDF() async {
    try {
      // Get temporary directory
      final dir = await getTemporaryDirectory();
      // Define the local file path
      _localPath = '${dir.path}/book.pdf';

      // Download the PDF
      final response = await Dio().download(widget.pdfUrl, _localPath);
      if (response.statusCode == 200) {
        setState(() {
          _isLoading = false; // PDF downloaded successfully
          // Initialize PDF controller with local file
          _pdfController = PdfController(
            document: PdfDocument.openFile(_localPath!),
          );
        });
      } else {
        print('Error downloading PDF: ${response.statusCode}');
        setState(() {
          _isLoading = false; // Set loading to false even if download fails
        });
      }
    } catch (e) {
      print("Error downloading PDF: $e");
      setState(() {
        _isLoading = false; // Set loading to false on error
      });
    }
  }

  Future<void> _updateReadingProgress() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final userId = currentUser?.uid;
      if (userId == null) return;

      final bookRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('history')
          .doc(widget.pdfUrl);

      await bookRef.set({
        'pdf_url': widget.pdfUrl,
        'last_read': Timestamp.now(),
        'current_page': _currentPage,
        'total_pages': _totalPages,
      }, SetOptions(merge: true));
    } catch (e) {
      print("Error updating reading progress: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Read Book'),
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.wb_sunny : Icons.nights_stay),
            onPressed: () {
              setState(() {
                _isDarkMode = !_isDarkMode;
              });
            },
          ),
        ],
      ),
      body: Container(
        color: _isDarkMode ? Colors.black : Colors.white,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator()) // Show loading indicator
            : PdfView(
                controller: _pdfController,
                scrollDirection: Axis.vertical,
                onDocumentLoaded: (document) {
                  setState(() {
                    _totalPages = document.pagesCount; // Set total pages
                  });
                  print('Document loaded: ${document.pagesCount} pages');
                },
                onPageChanged: (pageIndex) {
                  setState(() {
                    _currentPage = pageIndex;
                  });
                  _updateReadingProgress(); // Update progress in Firestore
                },
              ),
      ),
    );
  }

  @override
  void dispose() {
    _pdfController.dispose(); // Dispose of the controller when done
    super.dispose();
  }
}
