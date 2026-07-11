import 'package:alu_bridge/features/applications/bloc/applications_bloc.dart';
import 'package:alu_bridge/features/applications/data/application_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late ApplicationRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = ApplicationRepository(firestore: firestore);
  });

  Future<void> seedApplication({required String studentUid, required String oppTitle}) {
    return firestore.collection('applications').add({
      'oppId': 'opp1',
      'oppTitle': oppTitle,
      'ventureId': 'venture1',
      'studentUid': studentUid,
      'studentName': 'Ada',
      'studentHeadline': 'CS student',
      'matchScore': 80,
      'coverNote': '',
      'cvUrl': null,
      'status': 'submitted',
      'timeline': [
        {'status': 'submitted', 'at': Timestamp.now(), 'note': null},
      ],
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });
  }

  blocTest<ApplicationsBloc, ApplicationsState>(
    'emits only the applications belonging to the given student',
    setUp: () async {
      await seedApplication(studentUid: 'student1', oppTitle: 'Backend Intern');
      await seedApplication(studentUid: 'someone-else', oppTitle: 'Design Intern');
    },
    build: () => ApplicationsBloc(applicationRepository: repository, studentUid: 'student1'),
    act: (bloc) => bloc.add(const ApplicationsSubscriptionRequested()),
    wait: const Duration(milliseconds: 300),
    expect: () => [
      isA<ApplicationsState>()
          .having((s) => s.status, 'status', ApplicationsStatus.loaded)
          .having((s) => s.applications.length, 'length', 1)
          .having((s) => s.applications.first.oppTitle, 'oppTitle', 'Backend Intern'),
    ],
  );
}
