import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bootstrap.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/empty_view.dart';
import '../bloc/chat_bloc.dart';
import '../data/message_repository.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    required this.conversationId,
    required this.currentUid,
    required this.title,
    super.key,
  });

  final String conversationId;
  final String currentUid;
  final String title;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _bodyController = TextEditingController();

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatBloc(
        messageRepository: sl<MessageRepository>(),
        conversationId: widget.conversationId,
        senderUid: widget.currentUid,
      )..add(const ChatSubscriptionRequested()),
      child: Builder(
        builder: (context) => _ChatScaffold(
          title: widget.title,
          currentUid: widget.currentUid,
          bodyController: _bodyController,
        ),
      ),
    );
  }
}

class _ChatScaffold extends StatelessWidget {
  const _ChatScaffold({
    required this.title,
    required this.currentUid,
    required this.bodyController,
  });

  final String title;
  final String currentUid;
  final TextEditingController bodyController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              listenWhen: (previous, current) =>
                  previous.sendError != current.sendError && current.sendError != null,
              listener: (context, state) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(state.sendError!)));
              },
              builder: (context, state) {
                if (state.loadError) {
                  return const EmptyView(
                    message: 'Could not load this conversation. Please try again.',
                    icon: Icons.error_outline,
                  );
                }
                if (state.messages.isEmpty) {
                  return Center(child: Text('Say hello!', style: AppTextStyles.sub));
                }
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(20),
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final message = state.messages.reversed.toList()[index];
                    final isMine = message.senderUid == currentUid;
                    return Align(
                      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        constraints: const BoxConstraints(maxWidth: 280),
                        decoration: BoxDecoration(
                          color: isMine ? AppColors.navy : AppColors.grey100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.body,
                              style: AppTextStyles.body.copyWith(
                                color: isMine ? Colors.white : AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              message.sentAt.shortDateTime,
                              style: AppTextStyles.tiny.copyWith(
                                color: isMine ? Colors.white70 : AppColors.grey400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: bodyController,
                      decoration: const InputDecoration(hintText: 'Message'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send, color: AppColors.navy),
                    onPressed: () {
                      final body = bodyController.text.trim();
                      if (body.isEmpty) return;
                      context.read<ChatBloc>().add(ChatMessageSent(body));
                      bodyController.clear();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
