import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_model.dart';
import '../models/review_model.dart';

class BookRepository {
  final CollectionReference _booksColl = FirebaseFirestore.instance.collection('books');

  Stream<List<BookModel>> getBooks() {
    return _booksColl.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return BookModel.fromSnapshot(doc as DocumentSnapshot<Map<String, dynamic>>);
      }).toList();
    });
  }

  // Ambil List Review
  Stream<List<ReviewModel>> getReviews(String bookId) {
    return _booksColl
        .doc(bookId)
        .collection('reviews')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReviewModel.fromSnapshot(doc))
            .toList());
  }

  // ✅ FUNGSI ADD REVIEW (YANG DIPERBAIKI)
  Future<void> addReview(String bookId, ReviewModel review) async {
    final bookRef = _booksColl.doc(bookId);
    final reviewRef = bookRef.collection('reviews').doc();

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final bookSnapshot = await transaction.get(bookRef);
      
      if (!bookSnapshot.exists) {
        throw Exception("Buku tidak ditemukan");
      }

      // 🔥 PERBAIKAN DISINI: Gunakan .data() agar tidak error jika field hilang
      final data = bookSnapshot.data() as Map<String, dynamic>;
      
      // Kalau 'rating' tidak ada, otomatis pakai 0.0
      double currentRating = (data['rating'] as num?)?.toDouble() ?? 0.0;
      
      // Kalau 'totalReviews' tidak ada, otomatis pakai 0
      int currentReviews = (data['totalReviews'] as num?)?.toInt() ?? 0;

      // Hitung Rating Baru
      double newRating = ((currentRating * currentReviews) + review.rating) / (currentReviews + 1);

      // Simpan Review
      transaction.set(reviewRef, review.toJson());

      // Update Info Buku (Ini akan otomatis membuat field rating jika belum ada)
      transaction.update(bookRef, {
        'rating': newRating,
        'totalReviews': currentReviews + 1,
      });
    });
  }

  // Fungsi CRUD Lainnya (Tetap Sama)
  Future<void> addBook(BookModel book) async {
    try {
      await _booksColl.add(book.toJson());
    } catch (e) {
      throw Exception('Gagal tambah buku: $e');
    }
  }

  Future<void> updateBook(String docId, Map<String, dynamic> data) async {
    try {
      await _booksColl.doc(docId).update(data);
    } catch (e) {
      throw Exception('Gagal update buku: $e');
    }
  }

  Future<void> deleteBook(String docId) async {
    try {
      await _booksColl.doc(docId).delete();
    } catch (e) {
      throw Exception('Gagal hapus buku: $e');
    }
  }
}