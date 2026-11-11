import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_tokens.dart';

/// Modal dialog présentant le rapport d'incident scellé avec son empreinte SHA-256 canonique.
class IncidentReportDialog extends StatelessWidget {
  final String integritySeal;
  final String? reportMarkdown;
  final String reason;

  const IncidentReportDialog({
    super.key,
    required this.integritySeal,
    this.reportMarkdown,
    required this.reason,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        side: const BorderSide(color: AppTokens.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTokens.dangerMuted,
                    borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  ),
                  child: const Icon(Icons.warning_amber_rounded, color: AppTokens.danger, size: 24),
                ),
                const SizedBox(width: AppTokens.spacingMd),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RAPPORT OFFICIEL SCELLÉ',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppTokens.danger,
                          letterSpacing: 0.6,
                        ),
                      ),
                      Text(
                        "Signal d'Urgence Validé",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTokens.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.spacingLg),

            const Text(
              'Numéro de Certification Officiel :',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTokens.textSecondary),
            ),
            const SizedBox(height: 6),

            // Empreinte SHA-256 en bloc monospace
            Container(
              padding: const EdgeInsets.all(AppTokens.spacingMd),
              decoration: BoxDecoration(
                color: AppTokens.surfaceInset,
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                border: Border.all(color: AppTokens.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      integritySeal,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: AppTokens.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 16, color: AppTokens.textSecondary),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: integritySeal));
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Numéro de certification copié'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.spacingMd),

            const Text(
              "Vos proches et les services d'assistance ont reçu votre position GPS exacte. Ce document certifié est sauvegardé en lieu sûr.",
              style: TextStyle(fontSize: 12, color: AppTokens.textSecondary, height: 1.4),
            ),
            const SizedBox(height: AppTokens.spacingLg),

            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTokens.primary,
                foregroundColor: AppTokens.white,
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                ),
              ),
              child: const Text('Fermer et Poursuivre la Sécurisation'),
            ),
          ],
        ),
      ),
    );
  }
}

