import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/borrowing_model.dart';

class BorrowRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Cek jumlah pinjaman aktif
  Future<int> getActiveBorrowCount(String userId) async {
    final snapshot = await _firestore
        .collection('borrowings')
        .where('user_id', isEqualTo: userId)
        .where('is_returned', isEqualTo: false)
        .get();
    return snapshot.docs.length;
  }

  // 2. Ambil List Peminjaman
  Stream<List<BorrowingModel>> getBorrowingsByUser(String userId) {
    return _firestore
        .collection('borrowings')
        .where('user_id', isEqualTo: userId)
        .orderBy('borrow_date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return BorrowingModel.fromSnapshot(doc);
      }).toList();
    });
  }

  // 3. Pinjam Buku (YANG DIUPDATE)
  Future<void> borrowBook(BorrowingModel borrowing, String bookId) async {
    final bookRef = _firestore.collection('books').doc(bookId);
    
    // ✅ PERUBAHAN DISINI: Gunakan ID dari model yang dikirim Controller
    // Jangan pakai .doc() kosong lagi.
    final borrowRef = _firestore.collection('borrowings').doc(borrowing.borrowingId);

    await _firestore.runTransaction((transaction) async {
      // Baca dulu
      final bookSnapshot = await transaction.get(bookRef);
      if (!bookSnapshot.exists) throw Exception("Buku hilang!");

      int currentStock = bookSnapshot.get('stock');
      if (currentStock <= 0) throw Exception("Stok habis!");

      // Update Stok
      transaction.update(bookRef, {'stock': currentStock - 1});
      
      // Simpan Peminjaman
      transaction.set(borrowRef, borrowing.toJson());
    });
  }

  // 4. Kembalikan Buku
  Future<void> returnBook(String borrowId, String bookId) async {
    final bookRef = _firestore.collection('books').doc(bookId);
    final borrowRef = _firestore.collection('borrowings').doc(borrowId);

    await _firestore.runTransaction((transaction) async {
      // Baca dulu (Read)
      final bookSnapshot = await transaction.get(bookRef);
      
      if (!bookSnapshot.exists) throw Exception("Buku tidak ditemukan!");

      // Update status (Write)
      transaction.update(borrowRef, {
        'is_returned': true,
        'return_date': Timestamp.now(),
      });

      // Kembalikan stok (Write)
      int currentStock = bookSnapshot.get('stock');
      transaction.update(bookRef, {'stock': currentStock + 1});
    });
  }
}