import 'dart:convert';

import 'package:buymarket_frontend/features/auth/screens/login_screen.dart';
import 'package:buymarket_frontend/features/auth/services/auth_api_services.dart';
import 'package:buymarket_frontend/features/auth/services/auth_services.dart';
import 'package:buymarket_frontend/features/seller/screens/seller_auth_required_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows the seller authentication options', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: SellerAuthRequiredScreen()),
    );

    expect(
      find.text(
        'Para poder vender tus productos debes iniciar sesión o registrarte.',
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('seller-login-button')), findsOneWidget);
    expect(find.byKey(const Key('seller-register-button')), findsOneWidget);
  });

  testWidgets('login returns to the previous publication flow', (
    tester,
  ) async {
    final authService = AuthServices(
      authApiServices: AuthApiServices(
        client: MockClient(
          (_) async => http.Response(jsonEncode(_authResponse), 200),
        ),
      ),
    );
    var resumed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LoginScreen(
                      authService: authService,
                      returnOnSuccess: true,
                    ),
                  ),
                );
                resumed = result == true;
              },
              child: const Text('Publicar'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Publicar'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('login-email-field')),
      'seller@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('login-password-field')),
      'password',
    );
    await tester.tap(find.byKey(const Key('password-login-button')));
    await tester.pumpAndSettle();

    expect(resumed, isTrue);
    expect(find.text('Publicar'), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });
}

const _authResponse = {
  'access_token': 'backend-token',
  'user': {
    'id': 'seller-1',
    'email': 'seller@example.com',
    'role': 'user',
    'firstName': 'Seller',
    'lastName': 'Test',
    'emailVerified': true,
  },
};
