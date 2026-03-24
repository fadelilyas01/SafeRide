import 'package:flutter/material.dart';
import '../widgets/chat_widget.dart';
import '../../core/theme/app_colors.dart';

class SupportChatScreen extends StatelessWidget {
  const SupportChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          children: [
            Text('Support SafeRide', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('En ligne', style: TextStyle(fontSize: 10, color: Colors.green)),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: AppColors.primary.withValues(alpha: 0.05),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Vous discutez avec un assistant. Temps de réponse habituel : < 2 min.',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          const Expanded(
            child: ChatWidget(rideId: 'SUPPORT_SIMULATION'),
          ),
        ],
      ),
    );
  }
}
