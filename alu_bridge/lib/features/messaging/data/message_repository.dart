import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/conversation.dart';
import '../models/message.dart';

class MessageRepository {
  MessageRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _conversations =>
      _firestore.collection('conversations');

  Future<Conversation> getOrCreateConversation({
    required String applicationId,
    required List<String> participants,
  }) async {
    final existing = await _conversations
        .where('applicationId', isEqualTo: applicationId)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      return Conversation.fromMap(existing.docs.first.data(), existing.docs.first.id);
    }

    final doc = _conversations.doc();
    final conversation = Conversation(
      id: doc.id,
      participants: participants,
      applicationId: applicationId,
      lastMessage: '',
      lastMessageAt: null,
    );
    await doc.set(conversation.toMap());
    return conversation;
  }

  Stream<List<Conversation>> watchForUser(String uid) {
    return _conversations.where('participants', arrayContains: uid).snapshots().map((snapshot) {
      final conversations =
          snapshot.docs.map((d) => Conversation.fromMap(d.data(), d.id)).toList();
      conversations.sort((a, b) {
        final aTime = a.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });
      return conversations;
    });
  }

  Stream<List<Message>> watchMessages(String conversationId) {
    return _conversations.doc(conversationId).collection('messages').snapshots().map((snapshot) {
      final messages = snapshot.docs.map((d) => Message.fromMap(d.data(), d.id)).toList();
      messages.sort((a, b) => a.sentAt.compareTo(b.sentAt));
      return messages;
    });
  }

  Future<void> sendMessage({
    required String conversationId,
    required String senderUid,
    required String body,
  }) async {
    final now = DateTime.now();
    final conversation = _conversations.doc(conversationId);
    await conversation.collection('messages').add(
      Message(id: '', senderUid: senderUid, body: body, sentAt: now).toMap(),
    );
    await conversation.update({'lastMessage': body, 'lastMessageAt': Timestamp.fromDate(now)});
  }
}
