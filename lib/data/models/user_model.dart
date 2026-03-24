import '../../domain/entities/user_entity.dart';
import '../../domain/entities/payment_method_entity.dart';
import '../../core/constants/app_constants.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.fullName,
    super.phoneNumber,
    required super.role,
    super.profileImageUrl,
    super.isVerified,
    super.emergencyContacts,
    super.paymentMethods,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    var contactsJson = json['emergencyContacts'] as List? ?? [];
    List<ContactEntity> contacts = contactsJson.map((c) => ContactModel.fromJson(c)).toList();

    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      role: json['role'] == 'driver' ? UserRole.driver : UserRole.passenger,
      profileImageUrl: json['profileImageUrl'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      emergencyContacts: contacts,
      paymentMethods: (json['paymentMethods'] as List? ?? [])
          .map((p) => PaymentMethodModel.fromJson(p))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'role': role == UserRole.driver ? 'driver' : 'passenger',
      'profileImageUrl': profileImageUrl,
      'isVerified': isVerified,
      'emergencyContacts': emergencyContacts.map((c) => ContactModel.fromEntity(c).toJson()).toList(),
      'paymentMethods': paymentMethods.map((p) => PaymentMethodModel.fromEntity(p).toJson()).toList(),
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      fullName: entity.fullName,
      phoneNumber: entity.phoneNumber,
      role: entity.role,
      profileImageUrl: entity.profileImageUrl,
      isVerified: entity.isVerified,
      emergencyContacts: entity.emergencyContacts,
      paymentMethods: entity.paymentMethods,
    );
  }
}

class ContactModel extends ContactEntity {
  const ContactModel({required super.name, required super.phoneNumber});

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
    };
  }

  factory ContactModel.fromEntity(ContactEntity entity) {
    return ContactModel(name: entity.name, phoneNumber: entity.phoneNumber);
  }
}

class PaymentMethodModel extends PaymentMethodEntity {
  const PaymentMethodModel({
    required super.id,
    required super.type,
    required super.last4,
    required super.brand,
    super.isDefault,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] as String,
      type: json['type'] as String,
      last4: json['last4'] as String,
      brand: json['brand'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'last4': last4,
      'brand': brand,
      'isDefault': isDefault,
    };
  }

  factory PaymentMethodModel.fromEntity(PaymentMethodEntity entity) {
    return PaymentMethodModel(
      id: entity.id,
      type: entity.type,
      last4: entity.last4,
      brand: entity.brand,
      isDefault: entity.isDefault,
    );
  }
}
