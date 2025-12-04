import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/auth_controller.dart';
import '../controllers/book_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/borrow_controller.dart';
import '../controllers/wishlist_controller.dart'; // ✅ Import Wishlist
import 'add_book_view.dart';
import 'book_detail_view.dart';

class DashboardView extends StatelessWidget {
  DashboardView({super.key});

  final AuthController authC = Get.find();
  final BookController bookC = Get.put(BookController());
  final DashboardController dashboardC = Get.put(DashboardController());
  final BorrowController borrowC = Get.put(BorrowController());
  final WishlistController wishlistC = Get.put(WishlistController());

  final List<String> categories = ["Semua", "Novel", "Komik", "Bisnis", "Self Improvement", "Sains"];

  final List<String> avatarList = [
    "https://i.pravatar.cc/150?img=1",
    "https://i.pravatar.cc/150?img=2",
    "https://i.pravatar.cc/150?img=3",
    "https://i.pravatar.cc/150?img=4",
    "https://i.pravatar.cc/150?img=5",
    "https://i.pravatar.cc/150?img=6",
    "https://i.pravatar.cc/150?img=7",
    "https://i.pravatar.cc/150?img=8",
    "https://i.pravatar.cc/150?img=9",
  ];

  final Map<String, Color> categoryColors = {
    "Novel": Colors.blue.shade50, "Komik": Colors.orange.shade50,
    "Bisnis": Colors.green.shade50, "Self Improvement": Colors.purple.shade50,
    "Sains": Colors.red.shade50, "Semua": Colors.grey.shade100,
  };

  final Map<String, Color> categoryTextColors = {
    "Novel": Colors.blue.shade800, "Komik": Colors.orange.shade800,
    "Bisnis": Colors.green.shade800, "Self Improvement": Colors.purple.shade800,
    "Sains": Colors.red.shade800, "Semua": Colors.black87,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack(
        index: dashboardC.tabIndex.value,
        children: [
          _buildHomeTab(),      // Tab 0: Home
          _buildWishlistTab(),  // Tab 1: Favorit (BARU)
          _buildActivityTab(),  // Tab 2: Aktivitas (Riwayat)
          _buildProfileTab(),   // Tab 3: Profil
        ],
      )),

      floatingActionButton: Obx(() {
        // Tombol hanya muncul di Tab Home (index 0) dan Admin
        bool isHome = dashboardC.tabIndex.value == 0;
        bool isAdmin = authC.userM.value?.role == 'admin';
        
        if (isHome && isAdmin) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               FloatingActionButton.small(
                heroTag: "seed",
                onPressed: () => bookC.seedDatabase(),
                backgroundColor: Colors.orange,
                child: const Icon(Icons.auto_fix_high, color: Colors.white),
              ),
              const SizedBox(height: 10),
              FloatingActionButton(
                heroTag: "add",
                onPressed: () => Get.to(() => AddBookView()),
                backgroundColor: const Color(0xFF1E88E5),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          );
        }
        return const SizedBox();
      }),

      // ✅ NAVBAR 4 ITEM
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: dashboardC.tabIndex.value,
        onTap: dashboardC.changeTabIndex,
        selectedItemColor: const Color(0xFF1E88E5),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true, // Tampilkan label
        type: BottomNavigationBarType.fixed, // Wajib fixed karena item > 3
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorit'), // Item Baru
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      )),
    );
  }

  // =========================================
  // 🏠 TAB 1: HOME (DENGAN AVATAR DI POJOK)
  // =========================================
  Widget _buildHomeTab() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER (SAPAAN + AVATAR + SEARCH)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Column(
              children: [
                // Baris Atas: Teks & Avatar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() => Text(
                          "Halo, ${authC.userM.value?.name ?? 'Teman'}! 👋",
                          style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                        )),
                        Text(
                          "Mau baca apa?",
                          style: GoogleFonts.poppins(
                            fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF1E88E5)
                          ),
                        ),
                      ],
                    ),
                    // ✅ AVATAR KECIL DI HOME (KLIK -> PROFIL)
                    GestureDetector(
                      onTap: () {
                        // Pindah ke Tab Profil (Index 3)
                        dashboardC.changeTabIndex(3);
                      },
                      child: Obx(() {
                        String? photoUrl = authC.userM.value?.photoUrl;
                        return CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: (photoUrl != null && photoUrl.isNotEmpty) 
                              ? NetworkImage(photoUrl) 
                              : null,
                          child: (photoUrl == null || photoUrl.isEmpty) 
                              ? const Icon(Icons.person, color: Colors.grey) 
                              : null,
                        );
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                
                // Search Bar
                TextField(
                  onChanged: (value) => bookC.searchKeyword.value = value,
                  decoration: InputDecoration(
                    hintText: "Cari judul buku...",
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Get.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ],
            ),
          ),
          
          // KATEGORI
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Row(
              children: categories.map((category) {
                return Obx(() {
                  bool isSelected = bookC.selectedCategory.value == category;
                  Color bg = categoryColors[category] ?? Colors.grey.shade100;
                  if (Get.isDarkMode) bg = isSelected ? const Color(0xFF1E88E5) : Colors.grey.shade800;
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Text(category, style: TextStyle(color: isSelected ? Colors.white : (Get.isDarkMode ? Colors.white : Colors.black87))),
                      selected: isSelected, selectedColor: const Color(0xFF1E88E5), backgroundColor: bg, side: BorderSide.none,
                      onSelected: (selected) { if (selected) bookC.selectedCategory.value = category; },
                    ),
                  );
                });
              }).toList(),
            ),
          ),

          // GRID BUKU
          Expanded(
            child: Obx(() {
              var displayBooks = bookC.filteredBooks;
              if (displayBooks.isEmpty) return Center(child: Text("Tidak ada buku.", style: GoogleFonts.poppins(color: Colors.grey)));

              return RefreshIndicator(
                onRefresh: () => bookC.refreshData(),
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, childAspectRatio: 0.63, crossAxisSpacing: 16, mainAxisSpacing: 16,
                  ),
                  itemCount: displayBooks.length,
                  itemBuilder: (context, index) => _buildBookCard(displayBooks[index]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }



  // =========================================
  // ❤️ TAB 2: FAVORIT (WISHLIST) - BARU!
  // =========================================
  Widget _buildWishlistTab() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text("Buku Favorit ❤️", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF1E88E5))),
          ),
          Expanded(
            child: Obx(() {
              // Filter buku dari daftar semua buku yang ID-nya ada di wishlist
              var favBooks = bookC.books.where((book) => wishlistC.isLiked(book.id)).toList();

              if (favBooks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.favorite_border, size: 60, color: Colors.grey),
                      const SizedBox(height: 10),
                      Text("Belum ada buku favorit.", style: GoogleFonts.poppins(color: Colors.grey)),
                    ],
                  ),
                );
              }

              // Gunakan Grid yang sama dengan Home
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, childAspectRatio: 0.63, crossAxisSpacing: 16, mainAxisSpacing: 16,
                ),
                itemCount: favBooks.length,
                itemBuilder: (context, index) => _buildBookCard(favBooks[index]),
              );
            }),
          ),
        ],
      ),
    );
  }

  // WIDGET KARTU BUKU (Dipakai Ulang di Home & Favorit)
  Widget _buildBookCard(dynamic book) {
    bool isPopular = book.stock > 5;
    return GestureDetector(
      onTap: () => Get.to(() => BookDetailView(book: book)),
      child: Stack( 
        children: [
          Container(
            decoration: BoxDecoration(
              color: Get.isDarkMode ? Colors.grey.shade900 : Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    child: Hero(tag: book.id, child: Image.network(book.imageUrl, width: double.infinity, fit: BoxFit.cover, errorBuilder: (ctx, err, st) => Container(color: Colors.grey.shade200, child: const Icon(Icons.broken_image)))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: categoryColors[book.category] ?? Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
                        child: Text(book.category, style: TextStyle(fontSize: 10, color: categoryTextColors[book.category] ?? Colors.black54, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Stok: ${book.stock}", style: TextStyle(fontSize: 11, color: book.stock > 0 ? Colors.green : Colors.red)),
                          Obx(() {
                            bool isLiked = wishlistC.isLiked(book.id);
                            return InkWell(
                              onTap: () => wishlistC.toggleWishlist(book.id),
                              child: Icon(
                                isLiked ? Icons.favorite : Icons.favorite_border,
                                color: isLiked ? Colors.pink : Colors.grey,
                                size: 20,
                              ),
                            );
                          })
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isPopular) Positioned(top: 0, left: 0, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: const BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.only(topLeft: Radius.circular(15), bottomRight: Radius.circular(10))), child: const Row(children: [Icon(Icons.star, size: 10, color: Colors.white), SizedBox(width: 2), Text("Populer", style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold))]))),
          
          if (authC.userM.value?.role == 'admin')
            Positioned(
              top: 8, right: 8,
              child: GestureDetector( 
                onTap: () {
                  Get.defaultDialog(
                    title: "Hapus Buku?", middleText: "Hapus '${book.title}'?",
                    textConfirm: "Hapus", textCancel: "Batal", confirmTextColor: Colors.white, buttonColor: Colors.red,
                    onConfirm: () { bookC.deleteBook(book.id); Get.back(); }
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]),
                  child: const Icon(Icons.delete, color: Colors.white, size: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }

 // =========================================
  // 📜 TAB 3: RIWAYAT / AKTIVITAS (DENGAN DENDA)
  // =========================================
  Widget _buildActivityTab() { 
    // Untuk format mata uang Rupiah
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          Padding(
            padding: const EdgeInsets.all(20), 
            child: Text("Riwayat Peminjaman", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF1E88E5)))
          ), 
          Expanded(
            child: Obx(() { 
              if (borrowC.myBorrowings.isEmpty) return Center(child: Text("Belum ada riwayat.", style: GoogleFonts.poppins(color: Colors.grey))); 

              return ListView.builder(
                padding: const EdgeInsets.all(16), 
                itemCount: borrowC.myBorrowings.length, 
                itemBuilder: (context, index) { 
                  final borrow = borrowC.myBorrowings[index]; 
                  final due = borrow.dueDate.toDate(); 
                  final now = DateTime.now(); 
                  final sisaHari = due.difference(now).inDays; 
                  int denda = 0; 
                  
                  // 🔥 LOGIKA PERHITUNGAN DENDA
                  // Denda: Rp 2.000 per hari
                  if (sisaHari < 0 && !borrow.isReturned) { 
                    denda = (sisaHari.abs()) * 2000; 
                  }
                  
                  String dendaText = currencyFormatter.format(denda);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16), 
                    elevation: 3, 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), 
                    child: Padding(
                      padding: const EdgeInsets.all(16), 
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, 
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                            children: [
                              // Status Peminjaman
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), 
                                decoration: BoxDecoration(
                                  color: borrow.isReturned ? Colors.green.shade100 : Colors.orange.shade100, 
                                  borderRadius: BorderRadius.circular(8)
                                ), 
                                child: Text(
                                  borrow.isReturned ? "Sudah Dikembalikan" : "Sedang Dipinjam", 
                                  style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold, 
                                    color: borrow.isReturned ? Colors.green : Colors.deepOrange
                                  )
                                )
                              ), 
                              
                              // Status Sisa Hari / Denda
                              if (!borrow.isReturned)
                                denda > 0
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), 
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade100, 
                                        borderRadius: BorderRadius.circular(8)
                                      ), 
                                      child: Text(
                                        "Terlambat ${sisaHari.abs()} hari", 
                                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)
                                      )
                                    )
                                  : Text(
                                      "Sisa $sisaHari hari", 
                                      style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)
                                    )
                            ]
                          ), 
                          
                          const SizedBox(height: 12), 
                          Text(
                            borrow.bookTitle, 
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)
                          ), 
                          
                          // 🔥 Tampilkan Denda jika ada
                          if (denda > 0 && !borrow.isReturned) ...[
                            const SizedBox(height: 8),
                            Text(
                              "DENDA: $dendaText", 
                              style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14)
                            ),
                          ],
                          
                          const SizedBox(height: 12), 
                          const Divider(), 
                          
                          // Tombol Kembalikan
                          if (!borrow.isReturned) 
                            SizedBox(
                              width: double.infinity, 
                              child: ElevatedButton(
                                onPressed: () {
                                  // Konfirmasi Pengembalian dan Denda (jika ada)
                                  Get.defaultDialog(
                                    title: "Konfirmasi Pengembalian",
                                    middleText: denda > 0 
                                      ? "Buku akan dikembalikan dengan denda $dendaText. Apakah Anda yakin?"
                                      : "Kembalikan buku ini sekarang?",
                                    textConfirm: "KEMBALIKAN",
                                    textCancel: "BATAL",
                                    confirmTextColor: Colors.white,
                                    buttonColor: const Color(0xFF1E88E5),
                                    onConfirm: () {
                                      borrowC.returnBook(borrow);
                                      Get.back();
                                    }
                                  );
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E88E5), foregroundColor: Colors.white), 
                                child: Text(denda > 0 ? "KEMBALIKAN & BAYAR DENDA" : "KEMBALIKAN BUKU")
                              )
                            ) 
                          else 
                            Text("Dikembalikan pada: ${borrow.returnDate?.toDate().toString().substring(0, 16) ?? '-'}", style: const TextStyle(fontSize: 12, color: Colors.grey))
                        ]
                      )
                    )
                  ); 
                }
              ); 
            })
          )
        ]
      )
    ); 
  }

  // 👤 TAB 4: PROFIL (LENGKAP DENGAN GAMIFIKASI)
  Widget _buildProfileTab() {
    return SingleChildScrollView( 
      child: Column(
        children: [
          Container(
            width: double.infinity, padding: const EdgeInsets.only(top: 60, bottom: 30),
            decoration: const BoxDecoration(color: Color(0xFF1E88E5), borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
            child: Column(
              children: [
                // FOTO PROFIL
                Obx(() {
                  String? photoUrl = authC.userM.value?.photoUrl;
                  return CircleAvatar(
                    radius: 50, 
                    backgroundColor: Colors.white, 
                    backgroundImage: (photoUrl != null && photoUrl.isNotEmpty) ? NetworkImage(photoUrl) : null,
                    child: (photoUrl == null || photoUrl.isEmpty) 
                        ? const Icon(Icons.person, size: 60, color: Color(0xFF1E88E5)) 
                        : null,
                  );
                }),
                const SizedBox(height: 16),
                Obx(() => Text(authC.userM.value?.name ?? "Pengguna", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white))),
                Obx(() => Text(authC.userM.value?.email ?? "-", style: GoogleFonts.poppins(color: Colors.white70))),
                const SizedBox(height: 10),
                
                // --- BAGIAN BARU: LEVEL & PANGKAT ---
                Obx(() {
                  String levelName = borrowC.getUserLevel();
                  Color badgeColor = borrowC.getLevelColor();
                  
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))]
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.military_tech, color: badgeColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          levelName,
                          style: TextStyle(fontWeight: FontWeight.bold, color: badgeColor, fontSize: 14),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "(${borrowC.totalBorrowHistory} Buku)",
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }),
                // -------------------------------------

                const SizedBox(height: 10),
                // Role Admin/User
                Obx(() => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.5))), child: Text(authC.userM.value?.role.toUpperCase() ?? "USER", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2, fontSize: 10)))),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          _buildSectionTitle("PENGATURAN AKUN"),
          
          // EDIT PROFIL POPUP
          _buildMenuTile(
            icon: Icons.edit, title: "Edit Profil", 
            onTap: () {
              final nameC = TextEditingController(text: authC.userM.value?.name);
              Get.defaultDialog(
                title: "Edit Profil",
                content: SizedBox( 
                  height: 300, 
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        const TabBar(labelColor: Color(0xFF1E88E5), unselectedLabelColor: Colors.grey, tabs: [Tab(text: "Ganti Nama"), Tab(text: "Pilih Avatar")]),
                        Expanded(
                          child: TabBarView(
                            children: [
                              Column(mainAxisAlignment: MainAxisAlignment.center, children: [TextField(controller: nameC, decoration: const InputDecoration(labelText: "Nama Lengkap", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person))), const SizedBox(height: 20), ElevatedButton(onPressed: () { if (nameC.text.isNotEmpty) authC.updateProfile(nameC.text); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E88E5), foregroundColor: Colors.white), child: const Text("Simpan Nama"))]),
                              GridView.builder(padding: const EdgeInsets.all(10), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10), itemCount: avatarList.length, itemBuilder: (context, index) { return GestureDetector(onTap: () { authC.updateProfilePicture(avatarList[index]); }, child: CircleAvatar(backgroundImage: NetworkImage(avatarList[index]), backgroundColor: Colors.grey.shade200)); }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                cancel: TextButton(onPressed: () => Get.back(), child: const Text("Tutup")),
              );
            }
          ),
          _buildMenuTile(icon: Icons.lock_outline, title: "Ganti Password", onTap: () => Get.snackbar("Info", "Fitur Ganti Password tersedia!")),
          _buildMenuTile(icon: Icons.badge_outlined, title: "Kartu Anggota Digital", onTap: () => Get.snackbar("Info", "Fitur Kartu Anggota segera hadir!")),

          _buildSectionTitle("PREFERENSI"),
          _buildMenuTile(icon: Icons.dark_mode_outlined, title: "Tema Gelap", trailing: Switch(value: Get.isDarkMode, onChanged: (val) { Get.changeTheme(val ? ThemeData.dark() : ThemeData.light()); }), onTap: () {}),
          _buildMenuTile(icon: Icons.notifications_outlined, title: "Notifikasi", onTap: () {}),
          
          _buildSectionTitle("LAINNYA"),
          _buildMenuTile(icon: Icons.help_outline, title: "Bantuan & FAQ", onTap: () {}),
          _buildMenuTile(icon: Icons.info_outline, title: "Tentang Aplikasi", onTap: () { Get.defaultDialog(title: "Library App v1.0", middleText: "Dibuat dengan Flutter & Firebase.", textConfirm: "Oke", confirmTextColor: Colors.white, buttonColor: const Color(0xFF1E88E5), onConfirm: () => Get.back()); }),

          const SizedBox(height: 20),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () => authC.logout(), icon: const Icon(Icons.logout), label: const Text("Keluar Aplikasi"), style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade50, foregroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 15))))),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 8), child: Align(alignment: Alignment.centerLeft, child: Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 1.2))));
  }

  Widget _buildMenuTile({required IconData icon, required String title, required VoidCallback onTap, Widget? trailing}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(color: Get.isDarkMode ? Colors.grey.shade900 : Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))], border: Border.all(color: Colors.grey.withValues(alpha: 0.1))),
      child: ListTile(
        leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: const Color(0xFF1E88E5), size: 20)),
        title: Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}