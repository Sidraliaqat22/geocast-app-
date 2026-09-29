import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String name;
  final String role;
  final String status;
  final int experience;

  // 1. Generative Constructor (Default)
  // Maqsad: Jab saari details mojud hon toh simple object banana.
  UserProfile(this.name, this.role, this.status, this.experience);

  // 2. Named Constructor
  // Maqsad: Sirf students ke liye ek khas identity dena (experience 0 set kar dena).
  UserProfile.student(String name)
      : name = name,
        role = 'Student',
        status = 'Learning',
        experience = 0;

  // 3. Redirecting Constructor
  // Maqsad: Short cut! Agar koi sirf naam bataye toh default "Developer" role set ho jaye.
  UserProfile.developer(String name) : this(name, 'Developer', 'Active', 1);

  // 4. Factory Constructor
  // Maqsad: Firestore se jab Map ki surat mein data aaye toh usay model mein badalna.
  factory UserProfile.fromFirestore(Map<String, dynamic> data) {
    return UserProfile(
      data['user_name'] ?? 'Guest',
      data['user_role'] ?? 'User',
      data['user_status'] ?? 'Offline',
      data['user_exp'] ?? 0,
    );
  }

  // 5. Constant Constructor
  // Maqsad: System Admins ke liye fixed data jo memory mein sirf ek baar save ho.
  const UserProfile.admin()
      : name = 'System Admin',
        role = 'Administrator',
        status = 'Super',
        experience = 10;
}