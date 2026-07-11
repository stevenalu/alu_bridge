import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'application_status.dart';

class TimelineEntry extends Equatable {
  const TimelineEntry({required this.status, required this.at, this.note});

  factory TimelineEntry.fromMap(Map<String, dynamic> map) {
    return TimelineEntry(
      status: ApplicationStatusX.fromValue(map['status'] as String),
      at: (map['at'] as Timestamp).toDate(),
      note: map['note'] as String?,
    );
  }

  final ApplicationStatus status;
  final DateTime at;
  final String? note;

  Map<String, dynamic> toMap() {
    return {'status': status.value, 'at': Timestamp.fromDate(at), 'note': note};
  }

  @override
  List<Object?> get props => [status, at, note];
}

class Application extends Equatable {
  const Application({
    required this.id,
    required this.oppId,
    required this.oppTitle,
    required this.ventureId,
    required this.studentUid,
    required this.studentName,
    required this.studentHeadline,
    required this.matchScore,
    required this.status,
    required this.timeline,
    required this.createdAt,
    required this.updatedAt,
    this.coverNote = '',
    this.cvUrl,
  });

  factory Application.fromMap(Map<String, dynamic> map, String id) {
    return Application(
      id: id,
      oppId: map['oppId'] as String,
      oppTitle: map['oppTitle'] as String,
      ventureId: map['ventureId'] as String,
      studentUid: map['studentUid'] as String,
      studentName: map['studentName'] as String,
      studentHeadline: map['studentHeadline'] as String? ?? '',
      matchScore: map['matchScore'] as int? ?? 0,
      coverNote: map['coverNote'] as String? ?? '',
      cvUrl: map['cvUrl'] as String?,
      status: ApplicationStatusX.fromValue(map['status'] as String),
      timeline: (map['timeline'] as List? ?? const [])
          .map((entry) => TimelineEntry.fromMap(entry as Map<String, dynamic>))
          .toList(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  String get displayTitle => oppTitle.isEmpty ? 'Untitled role' : oppTitle;

  final String id;
  final String oppId;
  final String oppTitle;
  final String ventureId;
  final String studentUid;
  final String studentName;
  final String studentHeadline;
  final int matchScore;
  final String coverNote;
  final String? cvUrl;
  final ApplicationStatus status;
  final List<TimelineEntry> timeline;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() {
    return {
      'oppId': oppId,
      'oppTitle': oppTitle,
      'ventureId': ventureId,
      'studentUid': studentUid,
      'studentName': studentName,
      'studentHeadline': studentHeadline,
      'matchScore': matchScore,
      'coverNote': coverNote,
      'cvUrl': cvUrl,
      'status': status.value,
      'timeline': timeline.map((entry) => entry.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  @override
  List<Object?> get props => [
        id,
        oppId,
        oppTitle,
        ventureId,
        studentUid,
        studentName,
        studentHeadline,
        matchScore,
        coverNote,
        cvUrl,
        status,
        timeline,
        createdAt,
        updatedAt,
      ];
}
