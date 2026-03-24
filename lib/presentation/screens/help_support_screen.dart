import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/glass_card.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Centre d\'Aide'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchHeader(theme),
            const SizedBox(height: 32),
            Text(
              'Comment pouvons-nous vous aider ?',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildSupportCategories(context),
            const SizedBox(height: 40),
            _buildContactSupportCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const TextField(
        decoration: InputDecoration(
          icon: Icon(Icons.search),
          hintText: 'Rechercher une aide...',
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSupportCategories(BuildContext context) {
    return Column(
      children: [
        _supportTile(
          context,
          icon: Icons.person_outline,
          title: 'Mon Compte',
          subtitle: 'Profil, vérification et sécurité',
          route: '/faq',
        ),
        _supportTile(
          context,
          icon: Icons.payment,
          title: 'Paiements & Tarifs',
          subtitle: 'Factures, modes de paiement et taxes',
          route: '/faq',
        ),
        _supportTile(
          context,
          icon: Icons.directions_car,
          title: 'Trajets & Sécurité',
          subtitle: 'Bouton SOS, partage et incidents',
          route: '/faq',
        ),
      ],
    );
  }

  Widget _supportTile(BuildContext context, {required IconData icon, required String title, required String subtitle, required String route}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        child: ListTile(
          leading: Icon(icon, color: AppColors.primary),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push(route),
        ),
      ),
    );
  }

  Widget _buildContactSupportCard(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.chat_bubble_outline, size: 48, color: AppColors.primary),
          const SizedBox(height: 16),
          const Text(
            'Vous ne trouvez pas de réponse ?',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Nos conseillers sont disponibles 24h/24 pour vous assister.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push('/support-chat'),
              child: const Text('DISCUTER AVEC LE SUPPORT'),
            ),
          ),
        ],
      ),
    );
  }
}
