import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum OpportunityStatus { live, draft, closed }

class Opportunity extends Equatable {
  const Opportunity({
    required this.id,
    required this.ventureId,
    required this.ventureName,
    required this.verified,
    required this.title,
    required this.function,
    required this.type,
    required this.location,
    required this.commitment,
    required this.duration,
    required this.stipend,
    required this.description,
    required this.responsibilities,
    required this.requiredSkills,
    required this.status,
    required this.applicantCount,
    required this.createdAt,
    this.ventureLogoUrl,
    this.closesAt,
  });

  factory Opportunity.fromMap(Map<String, dynamic> map, String id) {
    return Opportunity(
      id: id,
      ventureId: map['ventureId'] as String,
      ventureName: map['ventureName'] as String,
      ventureLogoUrl: map['ventureLogoUrl'] as String?,
      verified: map['verified'] as bool? ?? false,
      title: map['title'] as String,
      function: map['function'] as String,
      type: map['type'] as String,
      location: map['location'] as String,
      commitment: map['commitment'] as String,
      duration: map['duration'] as String,
      stipend: map['stipend'] as String,
      description: map['description'] as String,
      responsibilities: List<String>.from(map['responsibilities'] as List? ?? const []),
      requiredSkills: List<String>.from(map['requiredSkills'] as List? ?? const []),
      status: OpportunityStatus.values.byName(map['status'] as String),
      applicantCount: map['applicantCount'] as int? ?? 0,
      closesAt: (map['closesAt'] as Timestamp?)?.toDate(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  final String id;
  final String ventureId;
  final String ventureName;
  final String? ventureLogoUrl;
  final bool verified;
  final String title;
  final String function;
  final String type;
  final String location;
  final String commitment;
  final String duration;
  final String stipend;
  final String description;
  final List<String> responsibilities;
  final List<String> requiredSkills;
  final OpportunityStatus status;
  final int applicantCount;
  final DateTime? closesAt;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'ventureId': ventureId,
      'ventureName': ventureName,
      'ventureLogoUrl': ventureLogoUrl,
      'verified': verified,
      'title': title,
      'function': function,
      'type': type,
      'location': location,
      'commitment': commitment,
      'duration': duration,
      'stipend': stipend,
      'description': description,
      'responsibilities': responsibilities,
      'requiredSkills': requiredSkills,
      'status': status.name,
      'applicantCount': applicantCount,
      'closesAt': closesAt == null ? null : Timestamp.fromDate(closesAt!),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  @override
  List<Object?> get props => [
        id,
        ventureId,
        ventureName,
        ventureLogoUrl,
        verified,
        title,
        function,
        type,
        location,
        commitment,
        duration,
        stipend,
        description,
        responsibilities,
        requiredSkills,
        status,
        applicantCount,
        closesAt,
        createdAt,
      ];
}
