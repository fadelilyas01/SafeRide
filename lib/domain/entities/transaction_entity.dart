import 'package:equatable/equatable.dart';

class TransactionEntity extends Equatable {
  final String id;
  final String rideId;
  final double amount;
  final String currency;
  final DateTime date;
  final String status; // e.g., 'completed', 'failed'
  final String paymentMethodLast4;

  const TransactionEntity({
    required this.id,
    required this.rideId,
    required this.amount,
    required this.currency,
    required this.date,
    required this.status,
    required this.paymentMethodLast4,
  });

  @override
  List<Object?> get props => [id, rideId, amount, currency, date, status, paymentMethodLast4];
}
