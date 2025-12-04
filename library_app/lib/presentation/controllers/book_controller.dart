import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import '../../data/models/book_model.dart';
import '../../data/models/review_model.dart'; // Import Model Review
import '../../data/repositories/book_repository.dart';

class BookController extends GetxController {
  final BookRepository _repo = BookRepository();
  
  // List buku (Observable)
  var books = <BookModel>[].obs;
  var isLoading = false.obs;

  // Variable Filter & Search
  var selectedCategory = 'Semua'.obs;
  var searchKeyword = ''.obs;

  // Text Controllers untuk Form Tambah Buku
  final titleC = TextEditingController();
  final authorC = TextEditingController();
  final yearC = TextEditingController();
  final stockC = TextEditingController();
  final imageC = TextEditingController(); 
  final synopsisC = TextEditingController();
  final categoryC = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Bind stream agar data selalu update realtime dari Firestore
    books.bindStream(_repo.getBooks());
  }

  // 🔥 FUNGSI REFRESH (PULL TO REFRESH)
  Future<void> refreshData() async {
    // Simulasi delay loading
    await Future.delayed(const Duration(seconds: 1));
    books.bindStream(_repo.getBooks()); 
  }

  // ✅ LOGIC PENYARING BUKU (Filter Kategori & Search)
  List<BookModel> get filteredBooks {
    List<BookModel> tempBooks;

    // 1. Filter Berdasarkan Kategori
    if (selectedCategory.value == 'Semua') {
      tempBooks = books;
    } else {
      tempBooks = books.where((book) => book.category == selectedCategory.value).toList();
    }

    // 2. Filter Berdasarkan Keyword Pencarian
    if (searchKeyword.value.isEmpty) {
      return tempBooks;
    } else {
      return tempBooks.where((book) {
        return book.title.toLowerCase().contains(searchKeyword.value.toLowerCase()) ||
               book.author.toLowerCase().contains(searchKeyword.value.toLowerCase());
      }).toList();
    }
  }

  // ✅ FUNGSI TAMBAH BUKU MANUAL
  Future<void> addBook() async {
    if (titleC.text.isEmpty || authorC.text.isEmpty || stockC.text.isEmpty) {
      Get.snackbar('Error', 'Semua data wajib diisi (kecuali gambar opsional)', 
        backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      BookModel newBook = BookModel(
        id: '', 
        title: titleC.text,
        author: authorC.text,
        year: yearC.text,
        stock: int.parse(stockC.text),
        // Jika gambar kosong, pakai placeholder
        imageUrl: imageC.text.isEmpty ? 'https://via.placeholder.com/150' : imageC.text,
        synopsis: synopsisC.text.isEmpty ? 'Belum ada sinopsis.' : synopsisC.text,
        category: categoryC.text.isEmpty ? 'Umum' : categoryC.text,
      );

      await _repo.addBook(newBook);

      isLoading.value = false;
      Get.back(); // Tutup dialog/halaman
      Get.snackbar('Sukses', 'Buku berhasil ditambahkan!', 
        backgroundColor: Colors.green, colorText: Colors.white);
      
      // Bersihkan form
      titleC.clear(); authorC.clear(); yearC.clear(); stockC.clear(); 
      imageC.clear(); synopsisC.clear(); categoryC.clear();

    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Gagal', e.toString(), 
        backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // ✅ FUNGSI HAPUS BUKU
  Future<void> deleteBook(String bookId) async {
    try {
      await _repo.deleteBook(bookId);
      Get.snackbar('Terhapus', 'Buku berhasil dihapus', 
        backgroundColor: Colors.redAccent, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus: $e');
    }
  }

  // ✅ FITUR SEED DATABASE (Isi 10 Buku Otomatis)
  Future<void> seedDatabase() async {
    try {
      isLoading.value = true;
      
      // Data Dummy 10 Buku Lengkap
      List<Map<String, dynamic>> dummyBooks = [
        {
          "title": "Laskar Pelangi",
          "author": "Andrea Hirata",
          "year": "2005",
          "stock": 5,
          "category": "Novel",
          "image": "https://upload.wikimedia.org/wikipedia/id/8/8e/Laskar_pelangi_sampul.jpg",
          "synopsis": "Kisah perjuangan Laskar Pelangi di Belitong."
        },
        {
          "title": "Filosofi Teras",
          "author": "Henry Manampiring",
          "year": "2018",
          "stock": 7,
          "category": "Self Improvement",
          "image": "https://cdn.gramedia.com/uploads/items/filosofi_teras_cov.jpg",
          "synopsis": "Filsafat Stoa untuk mental yang tangguh."
        },
        {
          "title": "Atomic Habits",
          "author": "James Clear",
          "year": "2018",
          "stock": 4,
          "category": "Self Improvement",
          "image": "https://images-na.ssl-images-amazon.com/images/I/91bYsX41DVL.jpg",
          "synopsis": "Cara membangun kebiasaan baik."
        },
        {
          "title": "Dilan 1990",
          "author": "Pidi Baiq",
          "year": "2014",
          "stock": 6,
          "category": "Novel",
          "image": "https://upload.wikimedia.org/wikipedia/id/f/f9/Dilan_Bagian_Pertama_cover.jpg",
          "synopsis": "Kisah cinta Dilan dan Milea."
        },
        {
          "title": "Naruto Vol 1",
          "author": "Masashi Kishimoto",
          "year": "1999",
          "stock": 10,
          "category": "Komik",
          "image": "https://upload.wikimedia.org/wikipedia/en/9/94/NarutoCoverTankobon1.jpg",
          "synopsis": "Awal mula perjalanan Naruto Uzumaki menjadi Hokage."
        },
        {
          "title": "Harry Potter",
          "author": "J.K. Rowling",
          "year": "1997",
          "stock": 4,
          "category": "Novel",
          "image": "https://images-na.ssl-images-amazon.com/images/I/81iqZ2HHD-L.jpg",
          "synopsis": "Petualangan penyihir muda Harry Potter."
        },
        {
          "title": "Rich Dad Poor Dad",
          "author": "Robert Kiyosaki",
          "year": "1997",
          "stock": 8,
          "category": "Bisnis",
          "image": "https://images-na.ssl-images-amazon.com/images/I/81bsw6fnUiL.jpg",
          "synopsis": "Pelajaran finansial dari dua sosok ayah."
        },
        {
          "title": "One Piece Vol 1",
          "author": "Eiichiro Oda",
          "year": "1997",
          "stock": 8,
          "category": "Komik",
          "image": "https://upload.wikimedia.org/wikipedia/en/9/90/One_Piece%2C_Volume_1.jpg",
          "synopsis": "Luffy memulai petualangannya mencari One Piece."
        },
         {
          "title": "Sapiens",
          "author": "Yuval Noah Harari",
          "year": "2011",
          "stock": 3,
          "category": "Sains",
          "image": "https://images-na.ssl-images-amazon.com/images/I/713jIoMO3UL.jpg",
          "synopsis": "Sejarah singkat umat manusia."
        },
        {
          "title": "Negeri 5 Menara",
          "author": "Ahmad Fuadi",
          "year": "2009",
          "stock": 5,
          "category": "Novel",
          "image": "https://upload.wikimedia.org/wikipedia/id/f/f2/Negeri_5_Menara.jpg",
          "synopsis": "Man Jadda Wajada."
        }
      ];

      for (var data in dummyBooks) {
        BookModel book = BookModel(
          id: '',
          title: data['title'],
          author: data['author'],
          year: data['year'],
          stock: data['stock'],
          imageUrl: data['image'],
          synopsis: data['synopsis'],
          category: data['category'],
        );
        await _repo.addBook(book);
      }

      isLoading.value = false;
      Get.snackbar("Selesai!", "10 Buku ditambahkan.", backgroundColor: Colors.green, colorText: Colors.white);
      
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", e.toString());
    }
  }

  // ✅ FUNGSI TAMBAH REVIEW
  Future<void> addReview(String bookId, double rating, String comment, String userName, String userId) async {
    try {
      ReviewModel review = ReviewModel(
        id: '',
        userId: userId,
        userName: userName,
        rating: rating,
        comment: comment,
        timestamp: Timestamp.now(),
      );
      
      await _repo.addReview(bookId, review);
      Get.snackbar("Terima Kasih", "Ulasan Anda berhasil dikirim!", backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Gagal", "Gagal kirim ulasan: $e", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // ✅ STREAM REVIEW UNTUK DETAIL PAGE
  Stream<List<ReviewModel>> getReviews(String bookId) {
    return _repo.getReviews(bookId);
  }

} // <--- Pastikan kurung kurawal penutup ada di SINI (paling akhir)