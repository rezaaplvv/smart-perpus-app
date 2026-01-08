Smart Perpus App

Smart Perpus App adalah aplikasi Perpustakaan Digital modern berbasis Flutter dan Firebase yang dilengkapi dengan fitur manajemen peminjaman, sistem gamifikasi (Level dan Pangkat), serta fitur ulasan interaktif untuk meningkatkan minat baca pengguna.

Fitur Utama

Sistem Autentikasi: Proses Login dan Register yang aman menggunakan layanan Firebase Authentication.

Gamifikasi (User Level): Sistem pangkat otomatis bagi pengguna (Pemula, Kutu Buku, Pustakawan Cilik) berdasarkan akumulasi data buku yang telah diselesaikan.

Review dan Rating: Fitur pemberian ulasan dan rating bintang pada setiap koleksi buku yang tersinkronisasi secara realtime.

Manajemen Peminjaman: Sistem peminjaman dan pengembalian buku dengan penghitungan sisa masa pinjam serta denda keterlambatan secara otomatis.

Wishlist: Daftar buku favorit untuk menyimpan referensi bacaan di masa mendatang.

Smart Search: Pencarian buku berdasarkan judul atau penulis dilengkapi dengan filter kategori yang dinamis.

Dark Mode Support: Antarmuka aplikasi yang dapat menyesuaikan dengan tema sistem perangkat pengguna.

Screenshots

Berikut adalah beberapa tampilan utama dari aplikasi ini:

Home dan Filter Kategori

Detail Buku dan Ulasan

Riwayat Peminjaman dan Denda

Profil Pengguna dan Level

Teknologi yang Digunakan

Framework: Flutter

State Management: GetX

Database dan Authentication: Firebase (Cloud Firestore dan Firebase Auth)

Fonts: Google Fonts (Poppins)

Icons: Lucide Icons dan FontAwesome

Cara Menjalankan Proyek

Prasyarat

Flutter SDK telah terinstal pada perangkat pengembangan.

Proyek telah terhubung dengan layanan Firebase (konfigurasi google-services.json atau GoogleService-Info.plist).

Langkah Instalasi

Lakukan klon pada repository ini:
git clone https://www.google.com/search?q=https://github.com/rezaaplvv/smart-perpus-app.git

Masuk ke direktori proyek:
cd smart-perpus-app

Instal dependensi yang diperlukan:
flutter pub get

Jalankan aplikasi pada perangkat atau emulator:
flutter run

Lisensi

Proyek ini didistribusikan di bawah Lisensi MIT. Lihat file LICENSE untuk informasi lebih lanjut.

Dibuat oleh Reza (https://www.google.com/search?q=https://github.com/rezaaplvv)
