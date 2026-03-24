import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class KycScreen extends StatefulWidget {
  const KycScreen({super.key});

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  bool _licenseUploaded = false;
  bool _insuranceUploaded = false;
  bool _idUploaded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vérification Conducteur'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pour garantir la sécurité de nos passagers, vous devez fournir les documents suivants :',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            _buildDocItem('Permis de conduire', _licenseUploaded, (val) => setState(() => _licenseUploaded = val)),
            _buildDocItem('Assurance véhicule', _insuranceUploaded, (val) => setState(() => _insuranceUploaded = val)),
            _buildDocItem('Pièce d\'identité', _idUploaded, (val) => setState(() => _idUploaded = val)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (_licenseUploaded && _insuranceUploaded && _idUploaded)
                    ? () => context.go('/home')
                    : null,
                child: const Text('Soumettre pour vérification'),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => context.go('/home'),
                child: const Text('Passer (Mode démo)', style: TextStyle(color: AppColors.textSecondary)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocItem(String title, bool isUploaded, Function(bool) onToggle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Text(title),
        trailing: isUploaded 
            ? const Icon(Icons.check_circle, color: AppColors.accent)
            : const Icon(Icons.upload_file),
        onTap: () {
          // Simulation d'upload
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload de $title...')),
          );
          Future.delayed(const Duration(seconds: 1), () => onToggle(true));
        },
      ),
    );
  }
}
