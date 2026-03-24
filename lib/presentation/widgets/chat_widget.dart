import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import './glass_card.dart';

import '../../domain/entities/message_entity.dart';
import '../blocs/chat_bloc/chat_bloc.dart';
import '../blocs/chat_bloc/chat_event.dart';
import '../blocs/chat_bloc/chat_state.dart';
import '../blocs/auth_bloc/auth_bloc.dart';
import '../blocs/auth_bloc/auth_state.dart';

class ChatWidget extends StatefulWidget {
  final String rideId;
  const ChatWidget({super.key, required this.rideId});

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(WatchMessagesEvent(widget.rideId));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 100),
      child: GlassCard(
        blur: 20,
        opacity: colorScheme.brightness == Brightness.dark ? 0.4 : 0.8,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            _buildHeader(colorScheme),
            Expanded(child: _buildMessagesList(colorScheme)),
            _buildInput(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.1))),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: colorScheme.primary,
            child: Icon(Icons.person, color: colorScheme.onPrimary),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Votre chauffeur', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colorScheme.onSurface)),
              const Text('En ligne', style: TextStyle(color: Colors.green, fontSize: 12)),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.close, color: colorScheme.onSurface),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(ColorScheme colorScheme) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state is MessagesLoaded) {
          if (state.messages.isEmpty) {
            return Center(
              child: Text('Dites bonjour à votre chauffeur !', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6))),
            );
          }
          return ListView.builder(
            reverse: true,
            padding: const EdgeInsets.all(20),
            itemCount: state.messages.length,
            itemBuilder: (context, index) {
              final message = state.messages[index];
              final authState = context.read<AuthBloc>().state;
              bool isMe = false;
              if (authState is Authenticated) {
                isMe = message.senderId == authState.user.id;
              }

              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.7),
                  decoration: BoxDecoration(
                    color: isMe ? colorScheme.primary : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isMe ? 20 : 0),
                      bottomRight: Radius.circular(isMe ? 0 : 20),
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: isMe ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                      fontSize: 15,
                    ),
                  ),
                ),
              );
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildInput(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 10,
      ),
      color: colorScheme.surface.withValues(alpha: 0.5),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: TextStyle(fontSize: 15, color: colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Message...',
                hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5)),
                filled: true,
                fillColor: colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: colorScheme.secondary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.send_rounded, color: colorScheme.onSecondary, size: 20),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      final message = MessageEntity(
        id: '',
        senderId: authState.user.id,
        text: _controller.text.trim(),
        timestamp: DateTime.now(),
        rideId: widget.rideId,
      );
      context.read<ChatBloc>().add(SendMessageEvent(message));
      _controller.clear();
    }
  }
}
