import 'package:cloud_firestore/cloud_firestore.dart';

import '../../opportunities/models/opportunity.dart';
import '../../profile/models/student_profile.dart';
import '../models/application.dart';
import '../models/application_status.dart';
import 'match_score.dart';

class ApplicationRepository {
  ApplicationRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _applications =>
      _firestore.collection('applications');

  Future<bool> hasApplied({required String oppId, required String studentUid}) async {
    final snapshot = await _applications
        .where('oppId', isEqualTo: oppId)
        .where('studentUid', isEqualTo: studentUid)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  Future<Application> submit({
    required Opportunity opportunity,
    required StudentProfile? profile,
    required String studentUid,
    required String studentName,
    required String coverNote,
  }) async {
    final matchScore = calculateMatchScore(opportunity.requiredSkills, profile?.skills ?? []);
    final now = DateTime.now();
    final doc = _applications.doc();

    final application = Application(
      id: doc.id,
      oppId: opportunity.id,
      oppTitle: opportunity.title,
      ventureId: opportunity.ventureId,
      studentUid: studentUid,
      studentName: studentName,
      studentHeadline: profile?.headline ?? '',
      matchScore: matchScore,
      coverNote: coverNote,
      cvUrl: profile?.cvUrl,
      status: ApplicationStatus.submitted,
      timeline: [TimelineEntry(status: ApplicationStatus.submitted, at: now)],
      createdAt: now,
      updatedAt: now,
    );

    await doc.set(application.toMap());
    await _firestore
        .collection('opportunities')
        .doc(opportunity.id)
        .update({'applicantCount': FieldValue.increment(1)});

    return application;
  }

  Stream<List<Application>> watchByStudent(String studentUid) {
    return _applications.where('studentUid', isEqualTo: studentUid).snapshots().map(_sorted);
  }

  List<Application> _sorted(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final applications =
        snapshot.docs.map((d) => Application.fromMap(d.data(), d.id)).toList();
    applications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return applications;
  }
}
