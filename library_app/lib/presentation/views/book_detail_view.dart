import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // ✅ Pastikan plugin ini sudah ada di pubspec.yaml
import '../../data/models/book_model.dart';
import '../../data/models/review_model.dart';
import '../controllers/borrow_controller.dart';
import '../controllers/book_controller.dart'; 
import '../controllers/auth_controller.dart'; 

class BookDetailView extends StatelessWidget {
  final BookModel book;
  
  BookDetailView({super.key, required this.book});

  // Panggil controller yang dibutuhkan
  final BorrowController borrowC = Get.find(); 
  final BookController bookC = Get.find();
  final AuthController authC = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Detail Buku", style: GoogleFonts.poppins(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER GAMBAR
            Container(
              width: double.infinity,
              height: 300,
              color: Colors.grey.shade100,
              child: Center(
                child: Hero( 
                  tag: book.id,
                  child: Image.network(
                    book.imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (ctx, error, stackTrace) => 
                        const Icon(Icons.broken_image, size: 100, color: Colors.grey),
                  ),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. JUDUL & INFO
                  Text(
                    book.title,
                    style: GoogleFonts.poppins(
                      fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Penulis: ${book.author}  •  Tahun: ${book.year}",
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),

                  // ✅ TAMPILAN RATING (STATIC)
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: 4.5, // Nanti bisa diganti book.rating jika sudah ada di model
                        itemBuilder: (context, index) => const Icon(Icons.star, color: Colors.amber),
                        itemCount: 5,
                        itemSize: 20.0,
                        direction: Axis.horizontal,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "4.5 (10 Ulasan)", // Dummy data rating
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 3. STATUS STOK
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: book.stock > 0 ? Colors.green.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: book.stock > 0 ? Colors.green : Colors.red),
                    ),
                    child: Text(
                      book.stock > 0 ? "Stok Tersedia: ${book.stock}" : "Stok Habis",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: book.stock > 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 4. SINOPSIS
                  Text(
                    "Sinopsis",
                    style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.synopsis,
                    style: GoogleFonts.poppins(
                      fontSize: 14, color: Colors.grey.shade700, height: 1.6
                    ),
                    textAlign: TextAlign.justify,
                  ),

                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 10),

                  // ✅ 5. BAGIAN REVIEW (HEADER + TOMBOL)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Ulasan Pembaca", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                      TextButton.icon(
                        onPressed: () => _showRatingDialog(context),
                        icon: const Icon(Icons.edit),
                        label: const Text("Tulis Ulasan"),
                      )
                    ],
                  ),
                  
                  // ✅ LIST KOMENTAR (STREAM)
                  StreamBuilder<List<ReviewModel>>(
                    stream: bookC.getReviews(book.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(child: Text("Belum ada ulasan. Jadilah yang pertama!")),
                        );
                      }
                      
                      return ListView.builder(
                        shrinkWrap: true, // Agar bisa di dalam ScrollView
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final review = snapshot.data![index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              child: Text(review.userName.isNotEmpty ? review.userName[0].toUpperCase() : 'U'),
                            ),
                            title: Text(review.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RatingBarIndicator(
                                  rating: review.rating,
                                  itemBuilder: (context, index) => const Icon(Icons.star, color: Colors.amber),
                                  itemCount: 5,
                                  itemSize: 14.0,
                                ),
                                const SizedBox(height: 4),
                                Text(review.comment),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 50), // Jarak bawah agar tidak ketutup tombol
                ],
              ),
            ),
          ],
        ),
      ),
      
      // 6. TOMBOL PINJAM DI BAWAH
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: book.stock > 0 ? () {
              borrowC.borrowBook(book);
            } : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("PINJAM BUKU SEKARANG", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  // ✅ DIALOG INPUT RATING
  void _showRatingDialog(BuildContext context) {
    double userRating = 3.0;
    final commentC = TextEditingController();

    Get.defaultDialog(
      title: "Beri Ulasan",
      content: Column(
        children: [
          const Text("Bagaimana bukunya?"),
          const SizedBox(height: 10),
          RatingBar.builder(
            initialRating: 3,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
            onRatingUpdate: (rating) {
              userRating = rating;
            },
          ),
          const SizedBox(height: 10),
          TextField(
            controller: commentC,
            decoration: const InputDecoration(
              hintText: "Tulis komentar Anda...",
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      textConfirm: "Kirim",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFF1E88E5),
      onConfirm: () {
        if (commentC.text.isNotEmpty) {
          bookC.addReview(
            book.id, 
            userRating, 
            commentC.text, 
            authC.userM.value?.name ?? 'Anonim', 
            authC.userM.value?.userId ?? '',
          );
          Get.back();
        } else {
          Get.snackbar("Error", "Komentar tidak boleh kosong");
        }
      }
    );
  }
}