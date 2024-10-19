class Book {
  final String name;
  final String author;
  final String imageUrl;
  final String genre;
  final String description;
  final String pdfUrl;

  Book({
    required this.name,
    required this.author,
    required this.imageUrl,
    required this.genre,
    required this.description,
    required this.pdfUrl,
  });

  // Factory method to create a Book from Firestore document
  factory Book.fromMap(Map<String, dynamic> data) {
    return Book(
      name: data['name'] ?? 'Unknown Title',
      author: data['author'] ?? 'Unknown Author',
      imageUrl: data['imageUrl'] ?? '',
      genre: data['genre'] ?? 'Unknown',
      description: data['description'] ?? 'No description',
      pdfUrl: data['pdfUrl'] ?? '',
    );
  }

  // Method to convert Book to Map for saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'author': author,
      'imageUrl': imageUrl,
      'genre': genre,
      'description': description,
      'pdfUrl': pdfUrl,
    };
  }
}
