import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:readarc_admin_apk/User/book_page.dart';
import 'package:readarc_admin_apk/User/user_authservice.dart';
import 'package:readarc_admin_apk/theme_provider.dart';

class UserHomePage extends StatefulWidget {
  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  String? _username;
  String? _profileImageUrl;
  String? _selectedGenre;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await AuthService().getCurrentUser();

    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> userData = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userData.exists && userData.data() != null) {
        setState(() {
          _username = userData.data()!['name'];
          _profileImageUrl = userData.data()!['profileImageUrl'];
        });
      } else {
        print('User data not found in Firestore');
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/user-home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/user-profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: screenWidth * 0.1,
                      backgroundImage: _profileImageUrl != null
                          ? NetworkImage(_profileImageUrl!)
                          : const AssetImage('assets/ReadArc.png')
                              as ImageProvider,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Hi, ${_username ?? 'User'}',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        Navigator.pushNamed(context, '/search');
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.person),
                      onPressed: () {
                        Navigator.pushNamed(context, '/user-profile');
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Latest Books Section
            Text(
              'Latest Books',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('books')
                  .orderBy('added_date', descending: true)
                  .limit(6) // Limit to six books
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text('No latest books available.'));
                }

                final books = snapshot.data!.docs;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Two cards per row
                    childAspectRatio: 0.7, // Aspect ratio for card size
                    crossAxisSpacing: 8, // Spacing between columns
                    mainAxisSpacing: 8, // Spacing between rows
                  ),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookPage(),
                              settings: RouteSettings(arguments: book),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: book['image_url'] != null
                                      ? Image.network(
                                          book['image_url'],
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        )
                                      : const Icon(Icons.book, size: 60),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                book['name'] ?? 'Unknown Title',
                                style: Theme.of(context).textTheme.bodyLarge,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                book['author'] ?? 'Unknown Author',
                                style: Theme.of(context).textTheme.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Genre: ${book['genre'] ?? 'Unknown'}',
                                style: Theme.of(context).textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                book['description'] ??
                                    'No description available',
                                style: Theme.of(context).textTheme.bodySmall,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 20),

            // Genre Selection Section
            DropdownButtonFormField<String>(
              value: _selectedGenre,
              items: [
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
              ]
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
              decoration: const InputDecoration(labelText: 'Select Genre'),
            ),
            const SizedBox(height: 10),
            if (_selectedGenre != null)
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('books')
                    .where('genre', isEqualTo: _selectedGenre)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  final books = snapshot.data!.docs;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final book = books[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(8),
                          leading: book['image_url'] != null
                              ? Image.network(
                                  book['image_url'],
                                  width: 60,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.book, size: 60),
                          title: Text(book['name'] ?? 'Unknown Title'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(book['author'] ?? 'Unknown Author'),
                              Text('Genre: ${book['genre'] ?? 'Unknown'}'),
                              Text(
                                book['description'] ??
                                    'No description available',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookPage(),
                                settings: RouteSettings(arguments: book),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
