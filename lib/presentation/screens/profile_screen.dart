import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc/auth_bloc.dart';
import '../blocs/auth_bloc/auth_event.dart';
import '../blocs/auth_bloc/auth_state.dart';
import '../widgets/glass_card.dart';
import '../../domain/entities/user_entity.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import 'package:saferide/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  void _addContact() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(AppLocalizations.of(context)!.profileAddContactTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.profileNameLabel),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.profilePhoneLabel),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.commonCancel),
            ),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty && _phoneController.text.isNotEmpty) {
                  final newContacts = List<ContactEntity>.from(authState.user.emergencyContacts)
                    ..add(ContactEntity(
                      name: _nameController.text,
                      phoneNumber: _phoneController.text,
                    ));
                  context.read<AuthBloc>().add(UpdateEmergencyContactsRequested(newContacts));
                  _nameController.clear();
                  _phoneController.clear();
                  Navigator.pop(context);
                }
              },
              child: Text(AppLocalizations.of(context)!.commonAdd),
            ),
          ],
        ),
      );
    }
  }

  void _removeContact(int index) {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      final newContacts = List<ContactEntity>.from(authState.user.emergencyContacts)..removeAt(index);
      context.read<AuthBloc>().add(UpdateEmergencyContactsRequested(newContacts));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profileTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            final user = state.user;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(user),
                  const SizedBox(height: 24),
                  _buildPaymentSection(),
                  const SizedBox(height: 32),
                  Text(
                    AppLocalizations.of(context)!.profileSosContacts,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.profileSosHint,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                  ),
                  const SizedBox(height: 16),
                  ...user.emergencyContacts.asMap().entries.map((entry) {
                    return _buildContactTile(entry.value, entry.key);
                  }),
                  const SizedBox(height: 16),
                  if (user.emergencyContacts.length < 5)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _addContact,
                        icon: const Icon(Icons.person_add_rounded),
                        label: Text(AppLocalizations.of(context)!.profileAddContact),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),
                  _buildSupportSection(),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildSupportSection() {
    return GlassCard(
      child: ListTile(
        leading: const Icon(Icons.help_outline, color: AppColors.primary),
        title: const Text('Besoin d\'aide ?'),
        subtitle: const Text('Consulter la FAQ ou contacter le support'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/help-support'),
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Paiement',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GlassCard(
          child: ListTile(
            leading: const Icon(Icons.credit_card, color: AppColors.primary),
            title: const Text('Modes de paiement'),
            subtitle: const Text('Gérer vos cartes bancaires'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/payment-methods'),
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          child: ListTile(
            leading: const Icon(Icons.history, color: AppColors.primary),
            title: const Text('Historique des paiements'),
            subtitle: const Text('Voir vos reçus et transactions'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/transactions'),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(UserEntity user) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.accent.withValues(alpha: 0.2),
            child: const Icon(Icons.person, size: 48, color: AppColors.accent),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName ?? 'Utilisateur',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                ),
                Text(
                  user.email,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: user.role == UserRole.driver ? Colors.orange : Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user.role == UserRole.driver 
                      ? AppLocalizations.of(context)!.profileRoleDriver 
                      : AppLocalizations.of(context)!.profileRolePassenger,
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile(ContactEntity contact, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: AppColors.accent,
          child: Icon(Icons.emergency_rounded, color: Colors.white, size: 20),
        ),
        title: Text(contact.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(contact.phoneNumber),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
          onPressed: () => _removeContact(index),
        ),
      ),
    );
  }
}
