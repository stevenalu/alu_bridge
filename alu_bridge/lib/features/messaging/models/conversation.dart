import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Conversation extends Equatable {
  const Conversation({
    required this.id,
    required this.participants,
    required this.applicationId,
    required this.lastMessage,
    required this.lastMessageAt,
  });

  factory Conversation.fromMap(Map<String, dynamic> map, String id) {
    return Conversation(
      id: id,
      participants: List<String>.from(map['participants'] as List? ?? const []),
      applicationId: map['applicationId'] as String,
      lastMessage: map['lastMessage'] as String? ?? '',
      lastMessageAt: (map['lastMessageAt'] as Timestamp?)?.toDate(),
    );
  }

  final String id;
  final List<String> participants;
  final String applicationId;
  final String lastMessage;
  final DateTime? lastMessageAt;

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'applicationId': applicationId,
      'lastMessage': lastMessage,
      'lastMessageAt': lastMessageAt == null ? null : Timestamp.fromDate(lastMessageAt!),
    };
  }

  @override
  List<Object?> get props => [id, participants, applicationId, lastMessage, lastMessageAt];
}
