import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedbackManagementPage extends StatelessWidget {
  const FeedbackManagementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Feedback Management'),
        ),
        body: const Center(child: Text('Please log in to view feedback.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback Management'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('feedbacks')
              .where('user_email', isEqualTo: currentUser.email)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              print('Error loading feedbacks: ${snapshot.error}');
              return const Center(child: Text('Error loading feedbacks.'));
            }

            final feedbacks = snapshot.data?.docs ?? [];

            if (feedbacks.isEmpty) {
              return const Center(
                  child: Text('No feedback available for you.'));
            }

            return ListView.builder(
              itemCount: feedbacks.length,
              itemBuilder: (context, index) {
                final feedback = feedbacks[index];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Book ID: ${feedback['book_id'] ?? "N/A"}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          'Rating: ${feedback['rating'] ?? "N/A"}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'Feedback:\n${feedback['feedback'] ?? "N/A"}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
