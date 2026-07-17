import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/config/google_auth_config.dart';

enum GoogleAuthFailureType { canceled, configuration, unavailable, token }

class GoogleAuthFailure implements Exception {
  const GoogleAuthFailure(this.type, [this.details]);

  final GoogleAuthFailureType type;
  final Object? details;

  @override
  String toString() => 'GoogleAuthFailure($type, $details)';
}

abstract interface class GoogleAuthProvider {
  Future<String> getIdToken();
  Future<void> signOut();
}

class GoogleSignInAuthProvider implements GoogleAuthProvider {
  GoogleSignInAuthProvider({
    GoogleSignIn? googleSignIn,
    TargetPlatform? platform,
    String? serverClientId,
  }) : _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
       _platform = platform ?? defaultTargetPlatform,
       _serverClientId = serverClientId ?? GoogleAuthConfig.serverClientId;

  final GoogleSignIn _googleSignIn;
  final TargetPlatform _platform;
  final String _serverClientId;
  Future<void>? _initialization;

  Future<void> _ensureInitialized() {
    final isSupportedPlatform =
        !kIsWeb &&
        (_platform == TargetPlatform.android ||
            _platform == TargetPlatform.iOS);
    if (!isSupportedPlatform) {
      throw const GoogleAuthFailure(GoogleAuthFailureType.unavailable);
    }

    if (_platform == TargetPlatform.android && _serverClientId.trim().isEmpty) {
      throw const GoogleAuthFailure(
        GoogleAuthFailureType.configuration,
        'Falta GOOGLE_SERVER_CLIENT_ID.',
      );
    }

    return _initialization ??= _googleSignIn.initialize(
      // iOS reads GIDClientID and GIDServerClientID from Info.plist.
      serverClientId: _platform == TargetPlatform.android
          ? _serverClientId
          : null,
    );
  }

  @override
  Future<String> getIdToken() async {
    try {
      await _ensureInitialized();

      if (!_googleSignIn.supportsAuthenticate()) {
        throw const GoogleAuthFailure(GoogleAuthFailureType.unavailable);
      }

      final account = await _googleSignIn.authenticate();
      final idToken = account.authentication.idToken;

      if (idToken == null || idToken.trim().isEmpty) {
        throw const GoogleAuthFailure(GoogleAuthFailureType.token);
      }

      return idToken;
    } on GoogleSignInException catch (error) {
      switch (error.code) {
        case GoogleSignInExceptionCode.canceled:
          throw GoogleAuthFailure(GoogleAuthFailureType.canceled, error);
        case GoogleSignInExceptionCode.clientConfigurationError:
        case GoogleSignInExceptionCode.providerConfigurationError:
          throw GoogleAuthFailure(GoogleAuthFailureType.configuration, error);
        default:
          throw GoogleAuthFailure(GoogleAuthFailureType.unavailable, error);
      }
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _ensureInitialized();
      await _googleSignIn.signOut();
    } catch (error) {
      debugPrint('No se pudo cerrar la sesion de Google: $error');
    }
  }
}
