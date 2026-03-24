import 'package:equatable/equatable.dart';
import '../../../domain/entities/message_entity.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object> get props => [];
}

class SendMessageEvent extends ChatEvent {
  final MessageEntity message;
  const SendMessageEvent(this.message);
  @override
  List<Object> get props => [message];
}

class WatchMessagesEvent extends ChatEvent {
  final String rideId;
  const WatchMessagesEvent(this.rideId);
  @override
  List<Object> get props => [rideId];
}

class MessagesUpdatedEvent extends ChatEvent {
  final List<MessageEntity> messages;
  const MessagesUpdatedEvent(this.messages);
  @override
  List<Object> get props => [messages];
}
