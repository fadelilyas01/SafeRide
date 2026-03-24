import 'package:equatable/equatable.dart';

class PaymentMethodEntity extends Equatable {
  final String id;
  final String type; // e.g., 'card'
  final String last4;
  final String brand; // e.g., 'visa', 'mastercard'
  final bool isDefault;

  const PaymentMethodEntity({
    required this.id,
    required this.type,
    required this.last4,
    required this.brand,
    this.isDefault = false,
  });

  @override
  List<Object?> get props => [id, type, last4, brand, isDefault];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'last4': last4,
      'brand': brand,
      'isDefault': isDefault,
    };
  }

  factory PaymentMethodEntity.fromJson(Map<String, dynamic> json) {
    return PaymentMethodEntity(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'card',
      last4: json['last4'] as String? ?? '',
      brand: json['brand'] as String? ?? 'visa',
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }
}
