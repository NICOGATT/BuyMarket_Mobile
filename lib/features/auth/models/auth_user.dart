class AuthUser {
  final String id;
  final String email;
  final String role;
  final String firstName;
  final String lastName;
  final bool emailVerified;

  AuthUser({
    required this.id,
    required this.email,
    required this.role,
    required this.firstName,
    required this.lastName,
    this.emailVerified = false,
  });

  bool get isEmailVerified => emailVerified;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final userJson = _userJson(json);
    final firstName = _readStringDeep(userJson, [
      'firstName',
      'first_name',
      'firstname',
      'given_name',
      'nombre',
    ]);
    final lastName = _readStringDeep(userJson, [
      'lastName',
      'last_name',
      'lastname',
      'familyName',
      'family_name',
      'familyname',
      'surname',
      'apellido',
    ]);
    final fallbackName = _splitFullName(
      _readStringDeep(userJson, [
        'name',
        'fullName',
        'full_name',
        'displayName',
        'display_name',
      ]),
    );

    return AuthUser(
      id: (userJson['sub'] ?? userJson['id'] ?? '').toString(),
      email: userJson['email']?.toString() ?? '',
      role: userJson['role']?.toString() ?? 'user',
      firstName: firstName.isNotEmpty ? firstName : fallbackName.$1,
      lastName: lastName.isNotEmpty ? lastName : fallbackName.$2,
      emailVerified:
          userJson['emailVerified'] == true ||
          userJson['isEmailVerified'] == true,
    );
  }

  static Map<String, dynamic> _userJson(Map<String, dynamic> json) {
    final user = json['user'];
    if (user is Map) {
      return {...json, ...Map<String, dynamic>.from(user)};
    }

    final data = json['data'];
    if (data is Map) {
      final dataMap = Map<String, dynamic>.from(data);
      final dataUser = dataMap['user'];
      if (dataUser is Map) {
        return {...json, ...dataMap, ...Map<String, dynamic>.from(dataUser)};
      }

      return {...json, ...dataMap};
    }

    return json;
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

  static String _readStringDeep(Map<String, dynamic> json, List<String> keys) {
    final directValue = _readString(json, keys);
    if (directValue.isNotEmpty) return directValue;

    for (final value in json.values) {
      final nestedValue = _readNestedString(value, keys);
      if (nestedValue.isNotEmpty) return nestedValue;
    }

    return '';
  }

  static String _readNestedString(dynamic value, List<String> keys) {
    if (value is Map) {
      final nestedMap = Map<String, dynamic>.from(value);
      final directValue = _readString(nestedMap, keys);
      if (directValue.isNotEmpty) return directValue;

      for (final nestedValue in nestedMap.values) {
        final result = _readNestedString(nestedValue, keys);
        if (result.isNotEmpty) return result;
      }
    }

    if (value is List) {
      for (final item in value) {
        final result = _readNestedString(item, keys);
        if (result.isNotEmpty) return result;
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
