import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../../domain/entities/transaction_entity.dart';


class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulation: Liste de transactions fictives
    final transactions = [
      TransactionEntity(
        id: 'TX1',
        rideId: 'R123',
        amount: 32.50,
        currency: 'CAD',
        date: DateTime.now().subtract(const Duration(days: 1)),
        status: 'completed',
        paymentMethodLast4: '4242',
      ),
      TransactionEntity(
        id: 'TX2',
        rideId: 'R124',
        amount: 15.00,
        currency: 'CAD',
        date: DateTime.now().subtract(const Duration(days: 3)),
        status: 'completed',
        paymentMethodLast4: '5555',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des Paiements'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final tx = transactions[index];
          return _buildTransactionItem(context, tx);
        },
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, TransactionEntity tx) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        child: ListTile(
          leading: const CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Icon(Icons.attach_money, color: Colors.white),
          ),
          title: Text('Trajet #${tx.rideId}'),
          subtitle: Text('${tx.date.day}/${tx.date.month}/${tx.date.year} • •••• ${tx.paymentMethodLast4}'),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${tx.amount.toStringAsFixed(2)} ${tx.currency}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                tx.status.toUpperCase(),
                style: TextStyle(
                  color: tx.status == 'completed' ? Colors.green : Colors.red,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
