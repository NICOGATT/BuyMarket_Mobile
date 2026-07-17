import 'dart:async';
import 'dart:convert';

import 'package:buymarket_frontend/core/routes/app_routes.dart';
import 'package:buymarket_frontend/features/auth/screens/login_screen.dart';
import 'package:buymarket_frontend/features/auth/services/auth_api_services.dart';
import 'package:buymarket_frontend/features/auth/services/auth_services.dart';
import 'package:buymarket_frontend/features/auth/services/google_auth_provider.dart';
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

  test('POST /auth/google sends only the Google ID token', () async {
    late http.Request capturedRequest;
    final api = AuthApiServices(
      client: MockClient((request) async {
        capturedRequest = request;
        return http.Response(jsonEncode(_authResponse), 201);
      }),
    );

    final response = await api.loginWithGoogle(idToken: 'google-id-token');

    expect(capturedRequest.method, 'POST');
    expect(capturedRequest.url.path, '/auth/google');
    expect(jsonDecode(capturedRequest.body), {'idToken': 'google-id-token'});
    expect(response.token, 'backend-token');
    expect(response.user.email, 'nico@example.com');
  });

  test('missing Android server client ID is a configuration error', () async {
    final provider = GoogleSignInAuthProvider(
      platform: TargetPlatform.android,
      serverClientId: '',
    );

    await expectLater(
      provider.getIdToken(),
      throwsA(
        isA<GoogleAuthFailure>().having(
          (error) => error.type,
          'type',
          GoogleAuthFailureType.configuration,
        ),
      ),
    );
  });

  test(
    'Google login persists the same app session as password login',
    () async {
      final google = _FakeGoogleAuthProvider(token: 'google-id-token');
      final service = _serviceWithSuccessfulBackend(google);

      await service.loginWithGoogle();

      final preferences = await SharedPreferences.getInstance();
      expect(service.isLoggeIn, isTrue);
      expect(service.token, 'backend-token');
      expect(service.user?.firstName, 'Nico');
      expect(preferences.getString(AuthServices.tokenKey), 'backend-token');
      expect(
        preferences.getString(AuthServices.userEmailKey),
        'nico@example.com',
      );

      final restored = _serviceWithSuccessfulBackend(google);
      await restored.checkSession();
      expect(restored.isLoggeIn, isTrue);
      expect(restored.user?.email, 'nico@example.com');
    },
  );

  test('logout clears the app session and signs out of Google', () async {
    final google = _FakeGoogleAuthProvider(token: 'google-id-token');
    final service = _serviceWithSuccessfulBackend(google);
    await service.loginWithGoogle();

    await service.logout();

    final preferences = await SharedPreferences.getInstance();
    expect(service.isLoggeIn, isFalse);
    expect(preferences.getString(AuthServices.tokenKey), isNull);
    expect(google.signOutCalls, 1);
  });

  testWidgets('Google login blocks both buttons and navigates once', (
    tester,
  ) async {
    final tokenCompleter = Completer<String>();
    final google = _FakeGoogleAuthProvider(completer: tokenCompleter);
    final service = _serviceWithSuccessfulBackend(google);

    await tester.pumpWidget(_testApp(service));
    await _tapGoogleButton(tester);

    final passwordButton = tester.widget<ElevatedButton>(
      find.byKey(const Key('password-login-button')),
    );
    final googleButton = tester.widget<OutlinedButton>(
      find.byKey(const Key('google-login-button')),
    );
    expect(passwordButton.onPressed, isNull);
    expect(googleButton.onPressed, isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    tokenCompleter.complete('google-id-token');
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('signed-in-home')), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });

  testWidgets('canceling Google login is silent', (tester) async {
    final google = _FakeGoogleAuthProvider(
      failure: const GoogleAuthFailure(GoogleAuthFailureType.canceled),
    );
    final service = _serviceWithSuccessfulBackend(google);

    await tester.pumpWidget(_testApp(service));
    await _tapGoogleButton(tester);
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('backend rejection shows a Google-specific error', (
    tester,
  ) async {
    final google = _FakeGoogleAuthProvider(token: 'rejected-token');
    final api = AuthApiServices(
      client: MockClient(
        (_) async => http.Response(jsonEncode({'message': 'invalid'}), 401),
      ),
    );
    final service = AuthServices(
      authApiServices: api,
      googleAuthProvider: google,
    );

    await tester.pumpWidget(_testApp(service));
    await _tapGoogleButton(tester);

    expect(find.textContaining('no pudo validar'), findsOneWidget);
  });
}

Future<void> _tapGoogleButton(WidgetTester tester) async {
  final button = find.byKey(const Key('google-login-button'));
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pump();
}

AuthServices _serviceWithSuccessfulBackend(GoogleAuthProvider google) {
  return AuthServices(
    googleAuthProvider: google,
    authApiServices: AuthApiServices(
      client: MockClient(
        (_) async => http.Response(jsonEncode(_authResponse), 200),
      ),
    ),
  );
}

Widget _testApp(AuthServices service) {
  return MaterialApp(
    home: LoginScreen(authService: service),
    routes: {
      AppRoutes.bottomNavigation: (_) =>
          const Scaffold(body: Text('Inicio', key: Key('signed-in-home'))),
    },
  );
}

const _authResponse = {
  'access_token': 'backend-token',
  'user': {
    'id': 'user-1',
    'email': 'nico@example.com',
    'role': 'user',
    'firstName': 'Nico',
    'lastName': 'Test',
    'emailVerified': true,
  },
};

class _FakeGoogleAuthProvider implements GoogleAuthProvider {
  _FakeGoogleAuthProvider({this.token, this.completer, this.failure});

  final String? token;
  final Completer<String>? completer;
  final GoogleAuthFailure? failure;
  int signOutCalls = 0;

  @override
  Future<String> getIdToken() async {
    if (failure case final failure?) throw failure;
    if (completer case final completer?) return completer.future;
    return token!;
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
  }
}
