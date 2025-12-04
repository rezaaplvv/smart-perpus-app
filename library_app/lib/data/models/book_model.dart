import 'package:cloud_firestore/cloud_firestore.dart';

class BookModel {
  final String id;
  final String title;
  final String author;
  final String year;
  final int stock;
  final String imageUrl;
  final String synopsis;
  final String category;
  // ✅ Field Baru untuk Rating
  final double rating;
  final int totalReviews;

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.year,
    required this.stock,
    required this.imageUrl,
    required this.synopsis,
    required this.category,
    this.rating = 0.0, // Default 0
    this.totalReviews = 0, // Default 0
  });

  factory BookModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return BookModel(
      id: snapshot.id,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      year: data['year'] ?? '',
      stock: data['stock'] ?? 0,
      imageUrl: data['image_url'] ?? '',
      synopsis: data['synopsis'] ?? 'Belum ada sinopsis.',
      category: data['category'] ?? 'Umum',
      // ✅ Ambil data rating
      rating: (data['rating'] ?? 0).toDouble(),
      totalReviews: data['totalReviews'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'author': author,
      'year': year,
      'stock': stock,
      'image_url': imageUrl,
      'synopsis': synopsis,
      'category': category,
      // ✅ Simpan data rating
      'rating': rating,
      'totalReviews': totalReviews,
    };
  }
}