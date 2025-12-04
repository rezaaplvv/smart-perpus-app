import 'package:cloud_firestore/cloud_firestore.dart';

class BorrowingModel {
  final String borrowingId;
  final String userId;
  final String bookId;
  final String bookTitle;
  final String bookAuthor;
  final Timestamp borrowDate;
  final Timestamp dueDate;
  final Timestamp? returnDate; // Bisa null kalau belum dikembalikan
  final int fine;
  final bool isReturned;

  BorrowingModel({
    required this.borrowingId,
    required this.userId,
    required this.bookId,
    required this.bookTitle,
    required this.bookAuthor,
    required this.borrowDate,
    required this.dueDate,
    this.returnDate,
    required this.fine,
    required this.isReturned,
  });

  factory BorrowingModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return BorrowingModel(
      borrowingId: snapshot.id,
      userId: data['user_id'] ?? '',
      bookId: data['book_id'] ?? '',
      bookTitle: data['book_title'] ?? '',
      bookAuthor: data['book_author'] ?? '',
      borrowDate: data['borrow_date'],
      dueDate: data['due_date'],
      returnDate: data['return_date'], // Bisa null
      fine: data['fine'] ?? 0,
      isReturned: data['is_returned'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'book_id': bookId,
      'book_title': bookTitle,
      'book_author': bookAuthor,
      'borrow_date': borrowDate,
      'due_date': dueDate,
      'return_date': returnDate,
      'fine': fine,
      'is_returned': isReturned,
    };
  }
}