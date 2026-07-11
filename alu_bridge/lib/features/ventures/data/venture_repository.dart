import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/venture.dart';

class VentureRepository {
  VentureRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _ventures =>
      _firestore.collection('ventures');

  Stream<Venture?> watchByFounder(String founderUid) {
    return _ventures.where('founderUid', isEqualTo: founderUid).limit(1).snapshots().map(
          (snapshot) => snapshot.docs.isEmpty
              ? null
              : Venture.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id),
        );
  }

  Future<Venture?> fetchByFounder(String founderUid) async {
    final snapshot =
        await _ventures.where('founderUid', isEqualTo: founderUid).limit(1).get();
    if (snapshot.docs.isEmpty) return null;
    return Venture.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id);
  }

  Future<void> submitForVerification({
    String? ventureId,
    required String founderUid,
    required String name,
    required String tagline,
    required String about,
    required String sector,
    required String proofUrl,
  }) async {
    final doc = ventureId != null ? _ventures.doc(ventureId) : _ventures.doc();
    final venture = Venture(
      id: doc.id,
      name: name,
      tagline: tagline,
      about: about,
      sector: sector,
      founderUid: founderUid,
      verification:
          VentureVerification(status: VerificationStatus.pending, proofUrl: proofUrl),
      createdAt: DateTime.now(),
    );
    await doc.set(venture.toMap());
  }
}
