import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Message extends Equatable {
  const Message({
    required this.id,
    required this.senderUid,
    required this.body,
    required this.sentAt,
  });

  factory Message.fromMap(Map<String, dynamic> map, String id) {
    return Message(
      id: id,
      senderUid: map['senderUid'] as String,
      body: map['body'] as String,
      sentAt: (map['sentAt'] as Timestamp).toDate(),
    );
  }

  final String id;
  final String senderUid;
  final String body;
  final DateTime sentAt;

  Map<String, dynamic> toMap() {
    return {'senderUid': senderUid, 'body': body, 'sentAt': Timestamp.fromDate(sentAt)};
  }

  @override
  List<Object?> get props => [id, senderUid, body, sentAt];
}
