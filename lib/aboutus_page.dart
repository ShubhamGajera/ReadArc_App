import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'About ReadArc',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'ReadArc is your ultimate destination for digital reading. '
              'Our mission is to provide a seamless and enjoyable reading experience for everyone. '
              'With a wide selection of books, easy navigation, and user-friendly features, '
              'we aim to create a community of readers who can access their favorite books anytime, anywhere.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32), // Increased spacing
            const Text(
              'Meet the Team',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.leaderboard, color: Colors.purple, size: 32),
                const SizedBox(width: 8),
                const Text(
                  'Leader: Gajera Shubham',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.person, color: Colors.purple, size: 32),
                const SizedBox(width: 8),
                const Text(
                  'Member: Atmin Jarasaniya',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32), // Increased spacing
            const Text(
              'Get in Touch',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Email: shubhamgajera122@gmail.com',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Follow us on social media for the latest updates!',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
