import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/book_controller.dart';

class AddBookView extends StatelessWidget {
  AddBookView({super.key});

  final BookController controller = Get.find(); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Buku Baru")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. INPUT LINK GAMBAR
            TextField(
              controller: controller.imageC,
              decoration: const InputDecoration(
                labelText: "Link Gambar (URL)",
                hintText: "https://...",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Judul Buku
            TextField(
              controller: controller.titleC,
              decoration: const InputDecoration(
                labelText: "Judul Buku",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.book),
              ),
            ),
            const SizedBox(height: 16),

            // 3. Penulis
            TextField(
              controller: controller.authorC,
              decoration: const InputDecoration(
                labelText: "Penulis",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),

            // ✅ 4. KATEGORI (BARU)
            TextField(
              controller: controller.categoryC,
              decoration: const InputDecoration(
                labelText: "Kategori (Contoh: Novel, Komik)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
            ),
            const SizedBox(height: 16),

            // 5. SINOPSIS
            TextField(
              controller: controller.synopsisC,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Sinopsis Singkat",
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.description),
              ),
            ),
            const SizedBox(height: 16),

            // 6. Tahun & Stok
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.yearC,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Tahun",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: controller.stockC,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Stok",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Tombol Simpan
            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value ? null : () => controller.addBook(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: controller.isLoading.value 
                    ? const Text("Menyimpan...") 
                    : const Text("SIMPAN BUKU"),
              )),
            ),
          ],
        ),
      ),
    );
  }
}