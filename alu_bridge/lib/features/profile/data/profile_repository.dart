import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/student_profile.dart';

class ProfileRepository {
  ProfileRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  Future<StudentProfile?> fetch(String uid) async {
    final doc = await _firestore.collection('students').doc(uid).get();
    if (!doc.exists) return null;
    return StudentProfile.fromMap(doc.data()!, uid);
  }

  Future<void> save(StudentProfile profile) {
    return _firestore.collection('students').doc(profile.uid).set(profile.toMap());
  }

  Future<void> setRoleSaved(String uid, String oppId, bool saved) {
    return _firestore.collection('students').doc(uid).update({
      'savedRoles':
          saved ? FieldValue.arrayUnion([oppId]) : FieldValue.arrayRemove([oppId]),
    });
  }
}
