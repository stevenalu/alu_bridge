import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum UserRole {
  student,
  founder;

  static UserRole fromValue(String value) => UserRole.values.byName(value);
}

class AppUser extends Equatable {
  const AppUser({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.role,
    required this.createdAt,
    this.photoUrl,
  });

  factory AppUser.fromMap(Map<String, dynamic> map, String uid) {
    return AppUser(
      uid: uid,
      email: map['email'] as String,
      fullName: map['fullName'] as String,
      role: UserRole.fromValue(map['role'] as String),
      photoUrl: map['photoUrl'] as String?,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  final String uid;
  final String email;
  final String fullName;
  final UserRole role;
  final String? photoUrl;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fullName': fullName,
      'role': role.name,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  @override
  List<Object?> get props => [uid, email, fullName, role, photoUrl, createdAt];
}
