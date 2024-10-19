import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:readarc_admin_apk/User/book_page.dart';
import 'package:readarc_admin_apk/User/bookmark_page.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _searchResults = [];
  List<String> _searchHistory = [];

  void _searchBooks() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    // Add to search history
    _addToSearchHistory(query);

    // Use a Set to avoid duplicates
    final Set<String> uniqueBookIds = {};

    // Search by name
    final nameResults = await FirebaseFirestore.instance
        .collection('books')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    for (var book in nameResults.docs) {
      uniqueBookIds.add(book.id); // Store unique book IDs
    }

    // Search by author
    final authorResults = await FirebaseFirestore.instance
        .collection('books')
        .where('author', isGreaterThanOrEqualTo: query)
        .where('author', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    for (var book in authorResults.docs) {
      uniqueBookIds.add(book.id);
    }

    // Search by genre
    final genreResults = await FirebaseFirestore.instance
        .collection('books')
        .where('genre', isGreaterThanOrEqualTo: query)
        .where('genre', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    for (var book in genreResults.docs) {
      uniqueBookIds.add(book.id);
    }

    // Fetch the unique books based on IDs
    final List<DocumentSnapshot> allResults = [];
    for (var id in uniqueBookIds) {
      final book =
          await FirebaseFirestore.instance.collection('books').doc(id).get();
      if (book.exists) {
        allResults.add(book);
      }
    }

    setState(() {
      _searchResults = allResults;
    });
  }

  void _addToSearchHistory(String query) {
    setState(() {
      if (!_searchHistory.contains(query)) {
        _searchHistory.add(query);
      }
    });
  }

  void _clearSearchHistory() {
    setState(() {
      _searchHistory.clear();
    });
  }

  void _removeFromSearchHistory(String query) {
    setState(() {
      _searchHistory.remove(query);
    });
  }

  Future<void> toggleBookmark(DocumentSnapshot book) async {
    final userId = 'YOUR_USER_ID'; // Replace with the current user's ID
    final bookmarksRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('bookmarks');

    final doc = await bookmarksRef.doc(book.id).get();

    if (doc.exists) {
      // Remove from bookmarks
      await bookmarksRef.doc(book.id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${book['name']} removed from bookmarks')),
      );
    } else {
      // Add to bookmarks
      await bookmarksRef.doc(book.id).set({
        'name': book['name'],
        'author': book['author'],
        'genre': book['genre'],
        'image_url': book['image_url'],
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${book['name']} added to bookmarks')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Books'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BookmarksPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by name, author, or genre',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchBooks,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _searchResults.isNotEmpty
                  ? ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final book = _searchResults[index];

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 10),
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
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Author: ${book['author']}',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Genre: ${book['genre']}',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 10),
                                // View Details Button
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BookPage(),
                                        settings:
                                            RouteSettings(arguments: book),
                                      ),
                                    );
                                  },
                                  child: const Text('View Details'),
                                ),
                                const SizedBox(height: 10),
                                // Bookmark Button
                                ElevatedButton(
                                  onPressed: () => toggleBookmark(book),
                                  child: const Text('Bookmark'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : ListView.builder(
                      itemCount: _searchHistory.length,
                      itemBuilder: (context, index) {
                        final historyItem = _searchHistory[index];
                        return ListTile(
                          leading: IconButton(
                            icon: const Icon(Icons.access_time),
                            onPressed: () {
                              _searchController.text = historyItem;
                              _searchBooks();
                            },
                          ),
                          title: Text(historyItem),
                          trailing: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _removeFromSearchHistory(historyItem);
                            },
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _clearSearchHistory,
              child: const Text('Clear Search History'),
            ),
          ],
        ),
      ),
    );
  }
}
