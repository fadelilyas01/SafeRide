import 'package:flutter/material.dart';
import '../../data/models/faq_model.dart';
import '../widgets/glass_card.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<FAQModel> faqs = [
      const FAQModel(
        question: 'Comment fonctionne le bouton SOS ?',
        answer: 'En appuyant sur SOS, vos contacts d\'urgence reçoivent immédiatement un SMS avec votre position en temps réel et un lien de suivi Firestore.',
        category: 'Sécurité',
      ),
      const FAQModel(
        question: 'Comment sont calculés les prix au Québec ?',
        answer: 'Nos tarifs incluent le prix de base + la TPS (5%) et la TVQ (9.975%) selon les normes en vigueur au Canada.',
        category: 'Paiement',
      ),
      const FAQModel(
        question: 'Comment devenir conducteur vérifié ?',
        answer: 'Vous devez soumettre vos documents (permis, assurance) via la section KYC. Notre équipe valide les dossiers sous 24h.',
        category: 'Compte',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Questions Fréquentes'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          final faq = faqs[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: GlassCard(
              child: ExpansionTile(
                title: Text(faq.question, style: const TextStyle(fontWeight: FontWeight.bold)),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(faq.answer),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
