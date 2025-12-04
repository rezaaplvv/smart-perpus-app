import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'presentation/controllers/auth_controller.dart'; // ✅ Import Controller
import 'presentation/views/onboarding_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();

  runApp(const MainApp());
}

// ✅ CLASS BINDING BARU
// Ini berfungsi untuk memasukkan Controller ke memori sejak awal
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // permanent: true artinya controller ini dilarang dihapus dari memori
    Get.put(AuthController(), permanent: true); 
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Perpus Digital',
      
      // ✅ PASANG BINDING DI SINI
      initialBinding: InitialBinding(),

      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5), 
          primary: const Color(0xFF4F46E5),
          secondary: const Color(0xFF10B981), 
          surface: Colors.white,
        ),
        primaryColor: const Color(0xFF4F46E5), 
        scaffoldBackgroundColor: const Color(0xFFF3F4F6), 
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1F2937), 
          elevation: 0,
          centerTitle: false, 
          scrolledUnderElevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4F46E5),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2)),
        ),
      ),
      
      themeMode: ThemeMode.light, 
   
      home: const OnboardingView(),
    );
  }
}