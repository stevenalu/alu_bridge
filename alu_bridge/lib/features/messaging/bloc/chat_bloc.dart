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

class ChatMessageSent extends ChatEvent {
  const ChatMessageSent(this.body);

  final String body;

  @override
  List<Object?> get props => [body];
}

class ChatState extends Equatable {
  const ChatState({this.messages = const []});

  final List<Message> messages;

  @override
  List<Object?> get props => [messages];
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
          onError: (_) => add(const ChatMessagesUpdated([])),
        );
  }

  void _onMessagesUpdated(ChatMessagesUpdated event, Emitter<ChatState> emit) {
    emit(ChatState(messages: event.messages));
  }

  Future<void> _onMessageSent(ChatMessageSent event, Emitter<ChatState> emit) {
    return _messageRepository.sendMessage(
      conversationId: _conversationId,
      senderUid: _senderUid,
      body: event.body,
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
