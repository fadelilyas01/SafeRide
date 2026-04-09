import 'package:flutter_test/flutter_test.dart';

import 'package:saferide/domain/entities/user_entity.dart';
import 'package:saferide/domain/entities/payment_method_entity.dart';
import 'package:saferide/core/constants/app_constants.dart';

void main() {
  group('UserEntity', () {
    const paymentMethod = PaymentMethodEntity(
      id: '1',
      type: 'card',
      last4: '4242',
      brand: 'visa',
      isDefault: true,
    );

    const user = UserEntity(
      id: '1',
      email: 'test@example.com',
      role: UserRole.passenger,
      paymentMethods: [paymentMethod],
    );

    test('should support equality', () {
      expect(
        user,
        const UserEntity(
          id: '1',
          email: 'test@example.com',
          role: UserRole.passenger,
          paymentMethods: [paymentMethod],
        ),
      );
    });

    test('should identify correctly as driver', () {
      const driver = UserEntity(
        id: '2',
        email: 'd@e.com',
        role: UserRole.driver,
      );
      expect(driver.role, UserRole.driver);
    });
  });

  group('PaymentMethodEntity', () {
    test('should support equality', () {
      const pm1 = PaymentMethodEntity(
        id: '1',
        type: 'card',
        last4: '4242',
        brand: 'visa',
      );
      const pm2 = PaymentMethodEntity(
        id: '1',
        type: 'card',
        last4: '4242',
        brand: 'visa',
      );
      expect(pm1, pm2);
    });
  });
}
