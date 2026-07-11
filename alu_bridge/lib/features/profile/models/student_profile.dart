import 'package:equatable/equatable.dart';

class StudentProfile extends Equatable {
  const StudentProfile({
    required this.uid,
    required this.headline,
    required this.programme,
    required this.yearOfStudy,
    required this.bio,
    required this.skills,
    required this.savedRoles,
    this.cvUrl,
  });

  factory StudentProfile.fromMap(Map<String, dynamic> map, String uid) {
    return StudentProfile(
      uid: uid,
      headline: map['headline'] as String? ?? '',
      programme: map['programme'] as String? ?? '',
      yearOfStudy: map['yearOfStudy'] as int? ?? 1,
      bio: map['bio'] as String? ?? '',
      skills: List<String>.from(map['skills'] as List? ?? const []),
      savedRoles: List<String>.from(map['savedRoles'] as List? ?? const []),
      cvUrl: map['cvUrl'] as String?,
    );
  }

  final String uid;
  final String headline;
  final String programme;
  final int yearOfStudy;
  final String bio;
  final List<String> skills;
  final List<String> savedRoles;
  final String? cvUrl;

  Map<String, dynamic> toMap() {
    return {
      'headline': headline,
      'programme': programme,
      'yearOfStudy': yearOfStudy,
      'bio': bio,
      'skills': skills,
      'savedRoles': savedRoles,
      'cvUrl': cvUrl,
    };
  }

  @override
  List<Object?> get props =>
      [uid, headline, programme, yearOfStudy, bio, skills, savedRoles, cvUrl];
}
