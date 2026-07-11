import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum VerificationStatus { pending, verified, rejected }

class VentureVerification extends Equatable {
  const VentureVerification({
    required this.status,
    this.proofUrl,
    this.reviewedAt,
    this.reviewedBy,
  });

  factory VentureVerification.fromMap(Map<String, dynamic> map) {
    return VentureVerification(
      status: VerificationStatus.values.byName(map['status'] as String),
      proofUrl: map['proofUrl'] as String?,
      reviewedAt: (map['reviewedAt'] as Timestamp?)?.toDate(),
      reviewedBy: map['reviewedBy'] as String?,
    );
  }

  final VerificationStatus status;
  final String? proofUrl;
  final DateTime? reviewedAt;
  final String? reviewedBy;

  Map<String, dynamic> toMap() {
    return {
      'status': status.name,
      'proofUrl': proofUrl,
      'reviewedAt': reviewedAt == null ? null : Timestamp.fromDate(reviewedAt!),
      'reviewedBy': reviewedBy,
    };
  }

  @override
  List<Object?> get props => [status, proofUrl, reviewedAt, reviewedBy];
}

class Venture extends Equatable {
  const Venture({
    required this.id,
    required this.name,
    required this.tagline,
    required this.about,
    required this.sector,
    required this.founderUid,
    required this.verification,
    required this.createdAt,
    this.logoUrl,
  });

  factory Venture.fromMap(Map<String, dynamic> map, String id) {
    return Venture(
      id: id,
      name: map['name'] as String,
      tagline: map['tagline'] as String,
      about: map['about'] as String,
      sector: map['sector'] as String,
      founderUid: map['founderUid'] as String,
      logoUrl: map['logoUrl'] as String?,
      verification:
          VentureVerification.fromMap(map['verification'] as Map<String, dynamic>),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  final String id;
  final String name;
  final String tagline;
  final String about;
  final String sector;
  final String founderUid;
  final VentureVerification verification;
  final DateTime createdAt;
  final String? logoUrl;

  bool get isVerified => verification.status == VerificationStatus.verified;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'tagline': tagline,
      'about': about,
      'sector': sector,
      'founderUid': founderUid,
      'logoUrl': logoUrl,
      'verification': verification.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  @override
  List<Object?> get props =>
      [id, name, tagline, about, sector, founderUid, verification, createdAt, logoUrl];
}
