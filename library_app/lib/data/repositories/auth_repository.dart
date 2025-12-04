import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mendapatkan user yang sedang login saat ini
  User? get currentUser => _auth.currentUser;

  // Fungsi Login
  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw Exception('Login Gagal: ${e.toString()}');
    }
  }

  // Fungsi Register (Buat Akun Auth + Simpan Data ke Firestore)
  Future<void> register(String email, String password, String name) async {
    try {
      // 1. Buat akun di Firebase Auth
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );

      // 2. Siapkan data user (Default role: user)
      UserModel newUser = UserModel(
        userId: cred.user!.uid,
        name: name,
        email: email,
        role: 'user', // Default user biasa
      );

      // 3. Simpan ke Firestore collection 'users'
      await _firestore
          .collection('users')
          .doc(newUser.userId)
          .set(newUser.toJson());
          
    } catch (e) {
      throw Exception('Register Gagal: ${e.toString()}');
    }
  }

  // Fungsi Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Ambil data detail user (termasuk Role) dari Firestore
  Future<UserModel?> getUserDetail(String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc = 
          await _firestore.collection('users').doc(uid).get();
      
      if (doc.exists) {
        return UserModel.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Gagal ambil data user: $e');
    }
  }
}