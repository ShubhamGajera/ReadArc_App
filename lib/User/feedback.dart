import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedbackPage extends StatefulWidget {
  final String bookId;

  const FeedbackPage({Key? key, required this.bookId}) : super(key: key);

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  double _rating = 0.0;
  final TextEditingController _feedbackController = TextEditingController();
  bool _isLoading = false;
  DocumentSnapshot? _bookDetails;

  @override
  void initState() {
    super.initState();
    _loadBookDetails();
  }

  Future<void> _loadBookDetails() async {
    final bookSnapshot = await FirebaseFirestore.instance
        .collection('books')
        .doc(widget.bookId)
        .get();

    if (bookSnapshot.exists) {
      setState(() {
        _bookDetails = bookSnapshot;
      });
    }
  }

  Future<void> _submitFeedback() async {
    if (_rating == 0.0 || _feedbackController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a rating and feedback.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final currentUser = FirebaseAuth.instance.currentUser;
    final userId = currentUser?.uid ?? '';
    final userEmail = currentUser?.email ?? '';

    try {
      await FirebaseFirestore.instance.collection('feedbacks').add({
        'book_id': widget.bookId,
        'user_id': userId,
        'user_email': userEmail,
        'rating': _rating,
        'feedback': _feedbackController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback submitted successfully!')),
      );
      Navigator.pop(context); // Close the feedback page after submission
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting feedback: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Feedback')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _bookDetails == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rate the Book',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          setState(() {
                            _rating = index + 1.0;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _feedbackController,
                    decoration: const InputDecoration(
                      labelText: 'Write your feedback',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitFeedback,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Submit Feedback'),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Book Details:',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  Text('Title: ${_bookDetails!['name'] ?? 'N/A'}'),
                  Text('Author: ${_bookDetails!['author'] ?? 'N/A'}'),
                  Text('Description: ${_bookDetails!['description'] ?? 'N/A'}'),
                ],
              ),
      ),
    );
  }
}
