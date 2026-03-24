import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository;
  StreamSubscription? _chatSubscription;

  ChatBloc({required ChatRepository chatRepository})
      : _chatRepository = chatRepository,
        super(ChatInitial()) {
    on<SendMessageEvent>(_onSendMessage);
    on<WatchMessagesEvent>(_onWatchMessages);
    on<MessagesUpdatedEvent>(_onMessagesUpdated);
  }

  Future<void> _onSendMessage(SendMessageEvent event, Emitter<ChatState> emit) async {
    await _chatRepository.sendMessage(event.message);
  }

  void _onWatchMessages(WatchMessagesEvent event, Emitter<ChatState> emit) {
    _chatSubscription?.cancel();
    _chatSubscription = _chatRepository.getMessages(event.rideId).listen(
      (messages) => add(MessagesUpdatedEvent(messages)),
    );
  }

  void _onMessagesUpdated(MessagesUpdatedEvent event, Emitter<ChatState> emit) {
    emit(MessagesLoaded(event.messages));
  }

  @override
  Future<void> close() {
    _chatSubscription?.cancel();
    return super.close();
  }
}
