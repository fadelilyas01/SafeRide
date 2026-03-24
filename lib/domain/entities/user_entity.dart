import 'package:equatable/equatable.dart';
import '../../core/constants/app_constants.dart';
import 'payment_method_entity.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? fullName;
  final String? phoneNumber;
  final UserRole role;
  final String? profileImageUrl;
  final bool isVerified;
  final List<ContactEntity> emergencyContacts;
  final List<PaymentMethodEntity> paymentMethods;

  const UserEntity({
    required this.id,
    required this.email,
    this.fullName,
    this.phoneNumber,
    required this.role,
    this.profileImageUrl,
    this.isVerified = false,
    this.emergencyContacts = const [],
    this.paymentMethods = const [],
  });

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        phoneNumber,
        role,
        profileImageUrl,
        isVerified,
        emergencyContacts,
        paymentMethods,
      ];
}

class ContactEntity extends Equatable {
  final String name;
  final String phoneNumber;

  const ContactEntity({
    required this.name,
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [name, phoneNumber];
}
