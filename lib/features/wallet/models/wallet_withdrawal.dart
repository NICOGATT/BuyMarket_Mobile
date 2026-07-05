class WalletWithdrawal {
  final String id;
  final double amount;
  final String? alias;
  final String? cbu;
  final String status;
  final String? adminNote;
  final DateTime? createdAt;

  const WalletWithdrawal({
    required this.id,
    required this.amount,
    required this.status,
    this.alias,
    this.cbu,
    this.adminNote,
    this.createdAt,
  });

  factory WalletWithdrawal.fromJson(Map<String, dynamic> json) {
    return WalletWithdrawal(
      id: _readString(json, 'id'),
      amount: _readDouble(json, 'amount'),
      alias: _readNullableString(json, 'alias'),
      cbu: _readNullableString(json, 'cbu'),
      status: _readString(json, 'status'),
      adminNote: _readNullableString(json, 'adminNote'),
      createdAt: _readDate(json, 'createdAt'),
    );
  }

  static String _readString(Map<String, dynamic> json, String key) {
    return json[key]?.toString() ?? '';
  }

  static String? _readNullableString(Map<String, dynamic> json, String key) {
    final value = json[key]?.toString().trim();
    return value == null || value.isEmpty ? null : value;
  }

  static double _readDouble(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _readDate(Map<String, dynamic> json, String key) {
    final value = json[key]?.toString();
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value)?.toLocal();
  }
}
