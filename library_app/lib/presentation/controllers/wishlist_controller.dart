import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'auth_controller.dart';

class WishlistController extends GetxController {
  final AuthController _authC = Get.find();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // List ID buku yang disukai (Realtime)
  var likedBookIds = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Pantau data favorit user secara realtime jika user sudah login
    if (_authC.userM.value != null) {
      String uid = _authC.userM.value!.userId;
      _firestore
          .collection('users')
          .doc(uid)
          .collection('favorites')
          .snapshots()
          .listen((snapshot) {
        likedBookIds.value = snapshot.docs.map((doc) => doc.id).toList();
      });
    }
  }

  // Cek apakah buku ini ada di favorit?
  bool isLiked(String bookId) {
    return likedBookIds.contains(bookId);
  }

  // Fungsi Toggle (Kalau ada hapus, kalau gak ada tambah)
  Future<void> toggleWishlist(String bookId) async {
    // Pastikan user ada
    if (_authC.userM.value == null) return;

    String uid = _authC.userM.value!.userId;
    DocumentReference docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(bookId);

    if (isLiked(bookId)) {
      // Hapus dari favorit
      await docRef.delete();
      Get.snackbar("Dihapus", "Buku dihapus dari favorit", 
        duration: const Duration(seconds: 1),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.grey.shade800, colorText: Colors.white);
    } else {
      // Tambah ke favorit
      await docRef.set({'added_at': Timestamp.now()});
      Get.snackbar("Disukai", "Buku masuk ke favorit ❤️", 
        duration: const Duration(seconds: 1),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.pink, colorText: Colors.white);
    }
  }
} 