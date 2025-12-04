import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_view.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        // SLIDE 1
        PageViewModel(
          title: "Perpustakaan dalam Genggaman",
          body: "Akses ribuan buku favoritmu kapan saja dan di mana saja hanya lewat HP.",
          image: _buildImage('https://cdn-icons-png.flaticon.com/512/3389/3389081.png'), // Gambar Buku
          decoration: _pageDecoration(),
        ),
        
        // SLIDE 2
        PageViewModel(
          title: "Pinjam Buku Mudah",
          body: "Tidak perlu antri. Cari buku, cek stok, dan pinjam langsung dari aplikasi.",
          image: _buildImage('https://cdn-icons-png.flaticon.com/512/2232/2232688.png'), // Gambar Peminjaman
          decoration: _pageDecoration(),
        ),
        
        // SLIDE 3
        PageViewModel(
          title: "Bebas Denda",
          body: "Kami akan mengingatkanmu sebelum waktu pengembalian habis agar terhindar dari denda.",
          image: _buildImage('https://cdn-icons-png.flaticon.com/512/4213/4213958.png'), // Gambar Notifikasi
          decoration: _pageDecoration(),
        ),
      ],
      onDone: () => _onIntroEnd(),
      onSkip: () => _onIntroEnd(), // Kalau tombol skip ditekan
      showSkipButton: true,
      skip: const Text("Lewati", style: TextStyle(fontWeight: FontWeight.w600)),
      next: const Icon(Icons.arrow_forward),
      done: const Text("Masuk", style: TextStyle(fontWeight: FontWeight.w600)),
      
      // Styling Dots (Titik Indikator)
      dotsDecorator: DotsDecorator(
        size: const Size.square(10.0),
        activeSize: const Size(20.0, 10.0),
        activeColor: const Color(0xFF1E88E5), // Warna Biru Aplikasi
        color: Colors.black26,
        spacing: const EdgeInsets.symmetric(horizontal: 3.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0)
        ),
      ),
    );
  }

  // Fungsi saat selesai onboarding -> Pindah ke Login
  void _onIntroEnd() {
    Get.off(() => LoginView());
  }

  // Helper untuk gambar
  Widget _buildImage(String assetName) {
    return Align(
      child: Image.network(assetName, width: 250.0),
      alignment: Alignment.bottomCenter,
    );
  }

  // Styling halaman
  PageDecoration _pageDecoration() {
    return PageDecoration(
      titleTextStyle: GoogleFonts.poppins(fontSize: 24.0, fontWeight: FontWeight.bold, color: const Color(0xFF1E88E5)),
      bodyTextStyle: GoogleFonts.poppins(fontSize: 16.0, color: Colors.grey[700]),
      bodyPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      // ✅ PERBAIKAN: Hapus 'const' di sini
      imagePadding: EdgeInsets.zero, 
    );
  }
}