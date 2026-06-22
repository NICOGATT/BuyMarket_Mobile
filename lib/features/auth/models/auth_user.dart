class AuthUser {
  final String id;
  final String email;
  final String role;
  final String firstName;
  final String lastName;

  AuthUser({
    required this.id,
    required this.email,
    required this.role,
    required this.firstName,
    required this.lastName,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final firstName = _readString(json, [
      'firstName',
      'first_name',
      'firstname',
      'given_name',
      'nombre',
    ]);
    final lastName = _readString(json, [
      'lastName',
      'last_name',
      'lastname',
      'family_name',
      'surname',
      'apellido',
    ]);
    final fallbackName = _splitFullName(_readString(json, [
      'name',
      'fullName',
      'full_name',
      'displayName',
      'display_name',
    ]));

    return AuthUser(
      id: json['sub'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      firstName: firstName.isNotEmpty ? firstName : fallbackName.$1,
      lastName: lastName.isNotEmpty ? lastName : fallbackName.$2,
    );
  }

  static String _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    return '';
  }

  static (String, String) _splitFullName(String fullName) {
    if (fullName.isEmpty) {
      return ('', '');
    }

    final parts = fullName.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return (parts.first, '');
    }

    return (parts.first, parts.sublist(1).join(' '));
  }
}
