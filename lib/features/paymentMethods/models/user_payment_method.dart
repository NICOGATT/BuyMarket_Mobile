class UserPaymentMethod {
  final String id;
  final String method;
  final String label;
  final bool isDefault;
  final bool isActive;
  final String? senderAlias;
  final String? senderCbu;

  const UserPaymentMethod({
    required this.id,
    required this.method,
    required this.label,
    required this.isDefault,
    required this.isActive,
    this.senderAlias,
    this.senderCbu,
  });

  factory UserPaymentMethod.fromJson(Map<String, dynamic> json) {
    return UserPaymentMethod(
      id: _readString(json, 'id'),
      method: _readString(json, 'method'),
      label: _readString(json, 'label'),
      isDefault: json['isDefault'] == true,
      isActive: json['isActive'] != false,
      senderAlias: _readNullableString(json, 'senderAlias'),
      senderCbu: _readNullableString(json, 'senderCbu'),
    );
  }

  String get displayMethod {
    switch (method) {
      case 'mercado_pago':
        return 'Mercado Pago';
      case 'transfer':
        return 'Transferencia';
      default:
        return method;
    }
  }

  bool get isMercadoPago => method == 'mercado_pago';
  bool get isTransfer => method == 'transfer';

  static String _readString(Map<String, dynamic> json, String key) {
    return json[key]?.toString() ?? '';
  }

  static String? _readNullableString(Map<String, dynamic> json, String key) {
    final value = json[key]?.toString().trim();
    return value == null || value.isEmpty ? null : value;
  }
}
