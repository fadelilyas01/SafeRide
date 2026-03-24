import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../../domain/entities/payment_method_entity.dart';
import '../../injection_container.dart';
import '../../data/datasources/stripe_service.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final List<PaymentMethodEntity> _paymentMethods = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Simulation: Charger des cartes existantes
    _paymentMethods.addAll([
      const PaymentMethodEntity(
        id: '1',
        type: 'card',
        last4: '4242',
        brand: 'visa',
        isDefault: true,
      ),
      const PaymentMethodEntity(
        id: '2',
        type: 'card',
        last4: '5555',
        brand: 'mastercard',
      ),
    ]);
  }

  Future<void> _addPaymentMethod() async {
    setState(() => _isLoading = true);
    try {
      final newMethod = await sl<StripeService>().addPaymentMethod();
      setState(() {
        // Enlever le par défaut des autres
        for (var i = 0; i < _paymentMethods.length; i++) {
          _paymentMethods[i] = PaymentMethodEntity(
            id: _paymentMethods[i].id,
            type: _paymentMethods[i].type,
            last4: _paymentMethods[i].last4,
            brand: _paymentMethods[i].brand,
            isDefault: false,
          );
        }
        _paymentMethods.add(newMethod);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Carte ajoutée avec succès !')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modes de Paiement'),
        centerTitle: true,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Vos Cartes Enregistrées',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              ..._paymentMethods.map((pm) => _buildPaymentCard(pm)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _addPaymentMethod,
                icon: const Icon(Icons.add),
                label: const Text('AJOUTER UNE CARTE'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              _buildSecurityInfo(),
            ],
          ),
    );
  }

  Widget _buildPaymentCard(PaymentMethodEntity pm) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        child: ListTile(
          leading: Icon(
            pm.brand == 'visa' ? Icons.credit_card : Icons.payment,
            color: AppColors.primary,
          ),
          title: Text('${pm.brand.toUpperCase()} •••• ${pm.last4}'),
          subtitle: pm.isDefault ? const Text('Par défaut', style: TextStyle(color: Colors.green)) : null,
          trailing: pm.isDefault ? const Icon(Icons.check_circle, color: Colors.green) : null,
          onTap: () {
            // Simulation : Changer la carte par défaut
            setState(() {
               for (var i = 0; i < _paymentMethods.length; i++) {
                _paymentMethods[i] = PaymentMethodEntity(
                  id: _paymentMethods[i].id,
                  type: _paymentMethods[i].type,
                  last4: _paymentMethods[i].last4,
                  brand: _paymentMethods[i].brand,
                  isDefault: _paymentMethods[i].id == pm.id,
                );
              }
            });
          },
        ),
      ),
    );
  }

  Widget _buildSecurityInfo() {
    return Column(
      children: [
        const Icon(Icons.security, color: Colors.grey, size: 24),
        const SizedBox(height: 8),
        Text(
          'Vos données bancaires sont cryptées et gérées par Stripe conforme aux normes PCI-DSS.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
