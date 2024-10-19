import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_storage_service.dart';

class UpdateBookPage extends StatefulWidget {
  final String bookId; // Book ID to be updated

  const UpdateBookPage({super.key, required this.bookId});

  @override
  _UpdateBookPageState createState() => _UpdateBookPageState();
}

class _UpdateBookPageState extends State<UpdateBookPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedGenre;

  File? _selectedImage;
  File? _selectedPdf;
  Uint8List? _webImage;
  Uint8List? _webPdf;

  bool _isLoading = false;
  final FirebaseStorageService _storageService = FirebaseStorageService();

  final List<String> _genres = [
    'Fiction',
    'Non-Fiction',
    'Science Fiction',
    'Fantasy',
    'Mystery',
    'Thriller',
    'Romance',
    'Historical',
    'Biography',
    'Self-Help',
    'Health',
    'Cookbook',
    'Graphic Novel',
    'Poetry',
    'Travel',
    'Children’s',
    'Young Adult',
    'Classic',
    'Adventure',
    'Science'
  ];

  @override
  void initState() {
    super.initState();
    _fetchBookData();
  }

  Future<void> _fetchBookData() async {
    try {
      DocumentSnapshot bookSnapshot = await FirebaseFirestore.instance
          .collection('books')
          .doc(widget.bookId)
          .get();

      if (bookSnapshot.exists) {
        var bookData = bookSnapshot.data() as Map<String, dynamic>;
        _nameController.text = bookData['name'];
        _authorController.text = bookData['author'];
        _descriptionController.text = bookData['description'];
        _selectedGenre = bookData['genre'];
      }
    } catch (e) {
      print('Error fetching book data: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      if (kIsWeb) {
        final result =
            await FilePicker.platform.pickFiles(type: FileType.image);
        if (result != null && result.files.single.bytes != null) {
          setState(() {
            _webImage = result.files.single.bytes;
            _selectedImage =
                null; // Clear mobile image if web image is selected
          });
        }
      } else {
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          setState(() {
            _selectedImage = File(pickedFile.path);
            _webImage = null; // Clear web image if mobile image is selected
          });
        }
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _pickPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null) {
        if (kIsWeb) {
          setState(() {
            _webPdf = result.files.single.bytes;
            _selectedPdf = null; // Clear mobile PDF if web PDF is selected
          });
        } else {
          setState(() {
            _selectedPdf = File(result.files.single.path!);
            _webPdf = null; // Clear web PDF if mobile PDF is selected
          });
        }
      }
    } catch (e) {
      print('Error picking PDF: $e');
    }
  }

  Future<void> _updateBookInFirebase(BuildContext context) async {
    final name = _nameController.text;
    final author = _authorController.text;
    final description = _descriptionController.text;

    if (name.isNotEmpty &&
        author.isNotEmpty &&
        description.isNotEmpty &&
        (_selectedImage != null || _webImage != null) &&
        (_selectedPdf != null || _webPdf != null) &&
        _selectedGenre != null) {
      setState(() => _isLoading = true);

      try {
        String? imageUrl, pdfUrl;

        // Handle image upload
        if (kIsWeb) {
          if (_webImage != null) {
            imageUrl = await _storageService.uploadFile(
              _webImage!,
              'Book/book_images/${DateTime.now().millisecondsSinceEpoch}.jpg',
              isWeb: true,
            );
          }
          if (_webPdf != null) {
            pdfUrl = await _storageService.uploadFile(
              _webPdf!,
              'Book/book_pdfs/${DateTime.now().millisecondsSinceEpoch}.pdf',
              isWeb: true,
            );
          }
        } else {
          if (_selectedImage != null) {
            imageUrl = await _storageService.uploadFile(
              _selectedImage!,
              'Book/book_images/${DateTime.now().millisecondsSinceEpoch}.jpg',
            );
          }
          if (_selectedPdf != null) {
            pdfUrl = await _storageService.uploadFile(
              _selectedPdf!,
              'Book/book_pdfs/${DateTime.now().millisecondsSinceEpoch}.pdf',
            );
          }
        }

        final currentUser = FirebaseAuth.instance.currentUser;
        final userId = currentUser?.uid ?? '';

        // Update the book document in Firestore
        await FirebaseFirestore.instance
            .collection('books')
            .doc(widget.bookId)
            .update({
          'name': name,
          'author': author,
          'description': description,
          'image_url': imageUrl ?? '',
          'pdf_url': pdfUrl ?? '',
          'genre': _selectedGenre,
          'uploader_id': userId,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book updated successfully!')),
        );

        Navigator.of(context).pop(); // Navigate back to the previous page
      } catch (e) {
        print('Error updating book: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update book.')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill in all fields and select files.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Update Book'), backgroundColor: Colors.purple),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            const Center(
              child: Text(
                'Update Book Information',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Book Name'),
            ),
            TextFormField(
              controller: _authorController,
              decoration: const InputDecoration(labelText: 'Author'),
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Select Genre'),
              value: _selectedGenre,
              items: _genres
                  .map((genre) => DropdownMenuItem(
                        value: genre,
                        child: Text(genre),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGenre = value;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text(_selectedImage != null || _webImage != null
                  ? 'Image Selected'
                  : 'Select Book Image'),
            ),
            ElevatedButton(
              onPressed: _pickPdf,
              child: Text(_selectedPdf != null || _webPdf != null
                  ? 'PDF Selected'
                  : 'Select Book PDF'),
            ),
            const SizedBox(height: 20),
            if (_webImage != null || _selectedImage != null)
              // Full picture of the selected book image
              Image.memory(
                _webImage ?? _selectedImage!.readAsBytesSync(),
                height: 250, // Bigger size for full display
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: () => _updateBookInFirebase(context),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text('Update Book'),
                  ),
          ],
        ),
      ),
    );
  }
}
