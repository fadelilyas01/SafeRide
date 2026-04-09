import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_model.dart';

class ChatService {
  final _supabase = Supabase.instance.client;

  /// Envoie un message de chat
  Future<void> sendMessage(String rideId, String message) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final chatMessage = ChatMessageModel(
      rideId: rideId,
      senderId: userId,
      message: message,
    );

    await _supabase
        .from('chat_messages')
        .insert(chatMessage.toMap());
  }

  /// Stream les messages d'une course en temps réel
  Stream<List<ChatMessageModel>> streamMessages(String rideId) {
    return _supabase
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .eq('ride_id', rideId)
        .order('created_at')
        .map((list) => list.map((json) => ChatMessageModel.fromJson(json)).toList());
  }
}
