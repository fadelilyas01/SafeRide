import 'package:flutter_test/flutter_test.dart';
import 'package:saferide/core/models/user_model.dart';

void main() {
  final tUserModel = UserModel(
    id: '1',
    role: UserRole.rider,
    firstName: 'Test',
    lastName: 'User',
    phone: '123456789',
    trustScore: 4.5,
    isKycVerified: true,
  );

  group('fromJson', () {
    test('should return a valid model when the JSON is correct', () {
      final Map<String, dynamic> jsonMap = {
        'id': '1',
        'role': 'rider',
        'first_name': 'Test',
        'last_name': 'User',
        'phone': '123456789',
        'trust_score': 4.5,
        'is_kyc_verified': true,
      };

      final result = UserModel.fromJson(jsonMap);

      expect(result.id, tUserModel.id);
      expect(result.firstName, tUserModel.firstName);
      expect(result.trustScore, 4.5);
    });
  });

  group('toMap', () {
    test('should return a Map containing the proper data', () {
      final result = tUserModel.toMap();

      final expectedMap = {
        'id': '1',
        'role': 'rider',
        'first_name': 'Test',
        'last_name': 'User',
        'phone': '123456789',
        'trust_score': 4.5,
        'is_kyc_verified': true,
        'is_women_safe': false,
      };

      expect(result, expectedMap);
    });
  });
}
