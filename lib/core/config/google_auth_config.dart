class GoogleAuthConfig {
  GoogleAuthConfig._();

  static const String serverClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
  );
}
