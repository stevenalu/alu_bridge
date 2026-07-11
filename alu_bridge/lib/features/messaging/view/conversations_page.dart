import 'package:flutter/material.dart';

import '../../../bootstrap.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/loading_list.dart';
import '../../applications/data/application_repository.dart';
import '../../ventures/data/venture_repository.dart';
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

class _ConversationInfo {
  const _ConversationInfo({required this.counterpartName, required this.roleTitle});

  final String counterpartName;
  final String roleTitle;
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.conversation, required this.currentUid});

  final Conversation conversation;
  final String currentUid;

  Future<_ConversationInfo> _load() async {
    final application = await sl<ApplicationRepository>().fetchById(conversation.applicationId);
    if (application == null) {
      return const _ConversationInfo(counterpartName: 'Conversation', roleTitle: '');
    }
    if (currentUid == application.studentUid) {
      final venture = await sl<VentureRepository>().fetchById(application.ventureId);
      return _ConversationInfo(
        counterpartName: venture?.name ?? 'Venture',
        roleTitle: application.displayTitle,
      );
    }
    return _ConversationInfo(
      counterpartName: application.studentName,
      roleTitle: application.displayTitle,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ConversationInfo>(
      future: _load(),
      builder: (context, snapshot) {
        final info = snapshot.data ??
            const _ConversationInfo(counterpartName: 'Conversation', roleTitle: '');
        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChatPage(
                conversationId: conversation.id,
                currentUid: currentUid,
                title: info.counterpartName,
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
                Text(info.counterpartName, style: AppTextStyles.h3),
                if (info.roleTitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(info.roleTitle, style: AppTextStyles.tiny),
                ],
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
