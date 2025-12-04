import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/book_model.dart';
import '../../data/models/borrowing_model.dart';
import '../../data/repositories/borrow_repository.dart';
import 'auth_controller.dart';

class BorrowController extends GetxController {
  final BorrowRepository _repo = BorrowRepository();
  final AuthController _authC = Get.find();

  var isLoading = false.obs;
  
  // List Peminjaman Saya (Realtime)
  var myBorrowings = <BorrowingModel>[].obs;

  // Total buku yang pernah dipinjam (untuk Gamifikasi)
  var totalBorrowHistory = 0.obs;

  @override
  void onInit() {
    super.onInit();
    if (_authC.userM.value != null) {
       String uid = _authC.userM.value!.userId;
       myBorrowings.bindStream(_repo.getBorrowingsByUser(uid));
       // Panggil fungsi hitung total history
       _countTotalHistory(uid);
    }
  }

  // Hitung total semua peminjaman (Aktif + Selesai) untuk Level
  void _countTotalHistory(String uid) {
    FirebaseFirestore.instance
      .collection('borrowings')
      .where('user_id', isEqualTo: uid)
      .snapshots()
      .listen((snapshot) {
        totalBorrowHistory.value = snapshot.docs.length;
      });
  }

  // 🔥 LOGIKA LEVEL (GAMIFIKASI)
  String getUserLevel() {
    int total = totalBorrowHistory.value;
    if (total <= 5) {
      return "Pemula 🌱";
    } else if (total > 5 && total <= 20) {
      return "Kutu Buku 🐛";
    } else {
      return "Pustakawan Cilik 👑";
    }
  }
  
  // Warna badge berdasarkan level
  Color getLevelColor() {
    int total = totalBorrowHistory.value;
    if (total <= 5) return Colors.green;
    if (total <= 20) return Colors.orange;
    return Colors.purple;
  }

  // FUNGSI PINJAM (DIPERBAIKI DENGAN OPTIMISTIC UPDATE)
  Future<void> borrowBook(BookModel book) async {
    isLoading.value = true;
    try {
      String uid = _authC.userM.value!.userId;
      
      // Cek Limit
      int activeCount = await _repo.getActiveBorrowCount(uid);
      if (activeCount >= 7) {
        Get.snackbar("Gagal", "Maksimal pinjam 7 buku!", backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      DateTime now = DateTime.now();
      DateTime dueDate = now.add(const Duration(days: 20));

      // 1. GENERATE ID SECARA MANUAL DI SINI
      String newId = FirebaseFirestore.instance.collection('borrowings').doc().id;

      BorrowingModel newBorrow = BorrowingModel(
        borrowingId: newId, 
        userId: uid,
        bookId: book.id,
        bookTitle: book.title,
        bookAuthor: book.author,
        borrowDate: Timestamp.fromDate(now),
        dueDate: Timestamp.fromDate(dueDate),
        isReturned: false,
        fine: 0,
        returnDate: null,
      );

      // 2. Kirim ke Database (Server)
      await _repo.borrowBook(newBorrow, book.id);
      
      // 3. OPTIMISTIC UPDATE (Update Tampilan Lokal)
      if (!myBorrowings.any((item) => item.borrowingId == newId)) {
         myBorrowings.insert(0, newBorrow);
      }
      
      Get.snackbar("Berhasil", "Buku dipinjam", backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // FUNGSI KEMBALIKAN BUKU (OPTIMISTIC UPDATE)
  Future<void> returnBook(BorrowingModel borrow) async {
    try {
      // 1. Eksekusi ke Database
      await _repo.returnBook(borrow.borrowingId, borrow.bookId);
      
      // 2. OPTIMISTIC UPDATE
      int index = myBorrowings.indexWhere((item) => item.borrowingId == borrow.borrowingId);
      
      if (index != -1) {
        BorrowingModel updatedItem = BorrowingModel(
          borrowingId: borrow.borrowingId,
          userId: borrow.userId,
          bookId: borrow.bookId,
          bookTitle: borrow.bookTitle,
          bookAuthor: borrow.bookAuthor,
          borrowDate: borrow.borrowDate,
          dueDate: borrow.dueDate,
          isReturned: true, 
          fine: borrow.fine,
          returnDate: Timestamp.now(),
        );
        
        myBorrowings[index] = updatedItem; 
        myBorrowings.refresh(); 
      }

      Get.snackbar("Terima Kasih", "Buku berhasil dikembalikan", backgroundColor: Colors.blue, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Gagal", e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}