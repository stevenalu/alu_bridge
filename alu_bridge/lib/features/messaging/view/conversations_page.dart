import 'package:flutter/material.dart';

import '../../../bootstrap.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/loading_list.dart';
import '../../applications/data/application_repository.dart';
import '../data/message_repository.dart';
import '../models/conversation.dart';
import 'chat_page.dart';

class ConversationsPage extends StatelessWidget {
  const ConversationsPage({required this.currentUid, super.key});

  final String currentUid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Conversation>>(
      stream: sl<MessageRepository>().watchForUser(currentUid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const EmptyView(
            message: 'Could not load conversations.',
            icon: Icons.error_outline,
          );
        }
        if (!snapshot.hasData) {
          return const LoadingList();
        }
        final conversations = snapshot.data!;
        if (conversations.isEmpty) {
          return const EmptyView(message: 'No conversations yet.');
        }
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: conversations.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _ConversationTile(
            conversation: conversations[index],
            currentUid: currentUid,
          ),
        );
      },
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.conversation, required this.currentUid});

  final Conversation conversation;
  final String currentUid;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: sl<ApplicationRepository>().fetchById(conversation.applicationId),
      builder: (context, snapshot) {
        final title = snapshot.data?.oppTitle ?? 'Conversation';
        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChatPage(
                conversationId: conversation.id,
                currentUid: currentUid,
                title: title,
              ),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.grey200),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.h3),
                if (conversation.lastMessage.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    conversation.lastMessage,
                    style: AppTextStyles.sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
