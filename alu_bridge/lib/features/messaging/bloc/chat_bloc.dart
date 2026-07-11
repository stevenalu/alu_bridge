import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/message_repository.dart';
import '../models/message.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class ChatSubscriptionRequested extends ChatEvent {
  const ChatSubscriptionRequested();
}

class ChatMessagesUpdated extends ChatEvent {
  const ChatMessagesUpdated(this.messages);

  final List<Message> messages;

  @override
  List<Object?> get props => [messages];
}

class ChatLoadFailed extends ChatEvent {
  const ChatLoadFailed();
}

class ChatMessageSent extends ChatEvent {
  const ChatMessageSent(this.body);

  final String body;

  @override
  List<Object?> get props => [body];
}

class ChatState extends Equatable {
  const ChatState({this.messages = const [], this.loadError = false, this.sendError});

  final List<Message> messages;
  final bool loadError;
  final String? sendError;

  @override
  List<Object?> get props => [messages, loadError, sendError];
}

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc({
    required MessageRepository messageRepository,
    required String conversationId,
    required String senderUid,
  })  : _messageRepository = messageRepository,
        _conversationId = conversationId,
        _senderUid = senderUid,
        super(const ChatState()) {
    on<ChatSubscriptionRequested>(_onSubscriptionRequested);
    on<ChatMessagesUpdated>(_onMessagesUpdated);
    on<ChatLoadFailed>(_onLoadFailed);
    on<ChatMessageSent>(_onMessageSent);
  }

  final MessageRepository _messageRepository;
  final String _conversationId;
  final String _senderUid;
  StreamSubscription<List<Message>>? _subscription;

  Future<void> _onSubscriptionRequested(
    ChatSubscriptionRequested event,
    Emitter<ChatState> emit,
  ) async {
    await _subscription?.cancel();
    _subscription = _messageRepository.watchMessages(_conversationId).listen(
          (messages) => add(ChatMessagesUpdated(messages)),
          onError: (_) => add(const ChatLoadFailed()),
        );
  }

  void _onMessagesUpdated(ChatMessagesUpdated event, Emitter<ChatState> emit) {
    emit(ChatState(messages: event.messages));
  }

  void _onLoadFailed(ChatLoadFailed event, Emitter<ChatState> emit) {
    emit(const ChatState(loadError: true));
  }

  Future<void> _onMessageSent(ChatMessageSent event, Emitter<ChatState> emit) async {
    try {
      await _messageRepository.sendMessage(
        conversationId: _conversationId,
        senderUid: _senderUid,
        body: event.body,
      );
      emit(ChatState(messages: state.messages, loadError: state.loadError));
    } catch (_) {
      emit(
        ChatState(
          messages: state.messages,
          loadError: state.loadError,
          sendError: 'Could not send that message. Please try again.',
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
