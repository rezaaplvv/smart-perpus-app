import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String userId;
  final String userName;
  final double rating; // 1.0 - 5.0
  final String comment;
  final Timestamp timestamp;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.timestamp,
  });

  factory ReviewModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return ReviewModel(
      id: snapshot.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anonim',
      // Menggunakan num agar aman jika di firebase tersimpan sebagai int (misal 4) atau double (misal 4.5)
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0, 
      comment: data['comment'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'timestamp': timestamp,
    };
  }
}