import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:readarc_admin_apk/User/book_page.dart';

class BookmarksPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userId = 'YOUR_USER_ID'; // Replace with the current user's ID

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('bookmarks')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading bookmarks'));
          }

          final bookmarks = snapshot.data!.docs;

          if (bookmarks.isEmpty) {
            return const Center(child: Text('No bookmarks yet.'));
          }

          return ListView.builder(
            itemCount: bookmarks.length,
            itemBuilder: (context, index) {
              final book = bookmarks[index];

              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Book Image
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(book['image_url']),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Book Details
                      Text(
                        book['name'],
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Author: ${book['author']}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Description:\n${book['description']}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 10),
                      // Remove Bookmark Button
                      ElevatedButton(
                        onPressed: () async {
                          await removeBookmark(userId,
                              book.id); // Call function to remove bookmark
                        },
                        child: const Text('Remove from Bookmarks'),
                      ),
                      const SizedBox(height: 10),
                      // Navigate to BookPage Button
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to BookPage and pass the book document snapshot
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookPage(),
                              settings: RouteSettings(arguments: book),
                            ),
                          );
                        },
                        child: const Text('View Details'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> removeBookmark(String userId, String bookId) async {
    final bookmarksRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('bookmarks');

    // Remove the bookmark document using the bookId
    await bookmarksRef.doc(bookId).delete();
  }
}
