import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String name;
  final String email;
  final String role; 
  final String photoUrl; // ✅ Field Baru

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    this.photoUrl = '', // Default kosong
  });

  factory UserModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return UserModel(
      userId: data['user_id'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
      photoUrl: data['photo_url'] ?? '', // ✅ Ambil dari firebase
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'role': role,
      'photo_url': photoUrl, // ✅ Simpan ke firebase
    };
  }
}