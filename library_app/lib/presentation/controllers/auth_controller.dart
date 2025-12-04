import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../views/register_view.dart';
import '../views/login_view.dart';
import '../views/dashboard_view.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepo = AuthRepository();

  final emailC = TextEditingController();
  final passwordC = TextEditingController();
  final nameC = TextEditingController();

  var isLoading = false.obs;
  
  // Data User (Role, Nama, dll)
  Rx<UserModel?> userM = Rx<UserModel?>(null);

  @override
  void onReady() {
    super.onReady();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    User? user = _authRepo.currentUser;
    if (user != null) {
      await _fetchUserDetail(user.uid);
    }
  }

  Future<void> _fetchUserDetail(String uid) async {
    try {
      userM.value = await _authRepo.getUserDetail(uid);
    } catch (e) {
      print("Gagal ambil data user: $e");
    }
  }

  // 🔥 FUNGSI UPDATE FOTO PROFIL (AVATAR)
  Future<void> updateProfilePicture(String imageUrl) async {
    try {
      isLoading.value = true;
      User? user = _authRepo.currentUser;
      if (user != null) {
        // 1. Update di Firebase Auth (Opsional, tapi bagus buat cache)
        await user.updatePhotoURL(imageUrl);
        
        // 2. Update di Firestore (Database utama kita)
        // Catatan: Pastikan di UserModel kamu sudah ada field 'photoUrl' atau sejenisnya.
        // Kalau belum, kita update field 'photo_url' di Firestore langsung.
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'photo_url': imageUrl,
        });

        // 3. Update Tampilan Lokal (Force Refresh)
        // Kita harus fetch ulang data user agar tampilan di dashboard berubah
        await _fetchUserDetail(user.uid);
        
        Get.back(); // Tutup Dialog
        Get.snackbar("Sukses", "Avatar berhasil diganti!", backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal ganti avatar: $e", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // FUNGSI UPDATE NAMA
  Future<void> updateProfile(String newName) async {
    try {
      isLoading.value = true;
      User? user = _authRepo.currentUser;
      if (user != null) {
        await user.updateDisplayName(newName);
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'name': newName,
        });
        
        await _fetchUserDetail(user.uid); // Refresh data
        
        Get.back();
        Get.snackbar("Sukses", "Nama profil berhasil diubah", backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal update profil: $e", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // FUNGSI GANTI PASSWORD
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      isLoading.value = true;
      User? user = _authRepo.currentUser;
      
      if (user != null && user.email != null) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!, password: currentPassword
        );
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPassword);
        
        Get.back();
        Get.snackbar("Sukses", "Password berhasil diganti. Silakan login ulang.", backgroundColor: Colors.green, colorText: Colors.white);
        logout();
      }
    } catch (e) {
      Get.snackbar("Gagal", "Password lama salah atau error lain: $e", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login() async {
    if (emailC.text.isEmpty || passwordC.text.isEmpty) {
      Get.snackbar('Error', 'Email dan Password harus diisi', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }
    try {
      isLoading.value = true;
      await _authRepo.login(emailC.text, passwordC.text);
      await _fetchUserDetail(_authRepo.currentUser!.uid);
      isLoading.value = false;
      Get.offAll(() => DashboardView()); 
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Login Gagal', e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> register() async {
    if (nameC.text.isEmpty || emailC.text.isEmpty || passwordC.text.isEmpty) {
      Get.snackbar('Error', 'Semua data harus diisi', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }
    try {
      isLoading.value = true;
      await _authRepo.register(emailC.text, passwordC.text, nameC.text);
      isLoading.value = false;
      Get.snackbar('Sukses', 'Akun berhasil dibuat. Silakan Login.', backgroundColor: Colors.green, colorText: Colors.white);
      Get.off(() => LoginView()); 
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Register Gagal', e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> logout() async {
    await _authRepo.logout();
    userM.value = null; 
    Get.offAll(() => LoginView());
  }

  void goToRegister() {
    Get.to(() => RegisterView());
  }
}