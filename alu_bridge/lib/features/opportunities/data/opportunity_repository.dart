import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/opportunity.dart';

class OpportunityRepository {
  OpportunityRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _opportunities =>
      _firestore.collection('opportunities');

  Stream<List<Opportunity>> watchByVenture(String ventureId) {
    return _opportunities
        .where('ventureId', isEqualTo: ventureId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Opportunity.fromMap(d.data(), d.id)).toList());
  }

  Stream<List<Opportunity>> watchLive() {
    return _opportunities
        .where('status', isEqualTo: OpportunityStatus.live.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Opportunity.fromMap(d.data(), d.id)).toList());
  }

  Future<String> save(Opportunity opportunity) async {
    final doc =
        opportunity.id.isEmpty ? _opportunities.doc() : _opportunities.doc(opportunity.id);
    await doc.set(opportunity.toMap());
    return doc.id;
  }

  Future<void> updateStatus(String oppId, OpportunityStatus status) {
    return _opportunities.doc(oppId).update({'status': status.name});
  }
}
