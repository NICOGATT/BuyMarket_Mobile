import 'package:buymarket_frontend/features/auth/models/auth_user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthUser', () {
    test('reads phone and both verification states', () {
      final user = AuthUser.fromJson({
        'id': 'user-1',
        'email': 'usuario@example.com',
        'firstName': 'Ana',
        'lastName': 'Pérez',
        'phoneNumber': '+54 11 1234-5678',
        'emailVerified': true,
        'phoneVerified': true,
      });

      expect(user.phone, '+54 11 1234-5678');
      expect(user.isEmailVerified, isTrue);
      expect(user.isPhoneVerified, isTrue);
    });

    test('keeps verification states when copying profile data', () {
      final user = AuthUser(
        id: 'user-1',
        email: 'usuario@example.com',
        role: 'user',
        firstName: 'Ana',
        lastName: 'Pérez',
        phone: '1122334455',
        emailVerified: true,
        phoneVerified: true,
      );

      final updated = user.copyWith(firstName: 'Anabella');

      expect(updated.firstName, 'Anabella');
      expect(updated.phone, '1122334455');
      expect(updated.isEmailVerified, isTrue);
      expect(updated.isPhoneVerified, isTrue);
    });
  });
}
