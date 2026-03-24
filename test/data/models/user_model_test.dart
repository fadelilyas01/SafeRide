import 'package:flutter_test/flutter_test.dart';
import 'package:saferide/data/models/user_model.dart';
import 'package:saferide/domain/entities/payment_method_entity.dart';
import 'package:saferide/core/constants/app_constants.dart';

void main() {
  const tUserModel = UserModel(
    id: '1',
    email: 'test@example.com',
    fullName: 'Test User',
    phoneNumber: '123456789',
    role: UserRole.passenger,
    isVerified: true,
    emergencyContacts: [],
    paymentMethods: [
      PaymentMethodEntity(
        id: 'pm_1',
        type: 'card',
        last4: '4242',
        brand: 'visa',
        isDefault: true,
      ),
    ],
  );

  group('fromJson', () {
    test('should return a valid model when the JSON is correct', () {
      final Map<String, dynamic> jsonMap = {
        'id': '1',
        'email': 'test@example.com',
        'fullName': 'Test User',
        'phoneNumber': '123456789',
        'role': 'passenger',
        'isVerified': true,
        'emergencyContacts': [],
        'paymentMethods': [
          {
            'id': 'pm_1',
            'type': 'card',
            'last4': '4242',
            'brand': 'visa',
            'isDefault': true,
          }
        ],
      };

      final result = UserModel.fromJson(jsonMap);

      expect(result.id, tUserModel.id);
      expect(result.email, tUserModel.email);
      expect(result.paymentMethods.length, 1);
      expect(result.paymentMethods[0].last4, '4242');
    });
  });

  group('toJson', () {
    test('should return a JSON map containing the proper data', () {
      final result = tUserModel.toJson();

      final expectedJsonMap = {
        'id': '1',
        'email': 'test@example.com',
        'fullName': 'Test User',
        'phoneNumber': '123456789',
        'role': 'passenger',
        'profileImageUrl': null,
        'isVerified': true,
        'emergencyContacts': [],
        'paymentMethods': [
          {
            'id': 'pm_1',
            'type': 'card',
            'last4': '4242',
            'brand': 'visa',
            'isDefault': true,
          }
        ],
      };

      expect(result, expectedJsonMap);
    });
  });
}
