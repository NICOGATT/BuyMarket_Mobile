class WalletTransaction {
  final String id;
  final String type;
  final double amount;
  final double commissionAmount;
  final double netAmount;
  final String status;
  final DateTime? createdAt;
  final String? orderId;

  const WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.commissionAmount,
    required this.netAmount,
    required this.status,
    this.createdAt,
    this.orderId,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: _readString(json, 'id'),
      type: _readString(json, 'type'),
      amount: _readDouble(json, 'amount'),
      commissionAmount: _readDouble(json, 'commissionAmount'),
      netAmount: _readDouble(json, 'netAmount'),
      status: _readString(json, 'status'),
      createdAt: _readDate(json, 'createdAt'),
      orderId: _readOrderId(json['order']),
    );
  }

  static String _readString(Map<String, dynamic> json, String key) {
    return json[key]?.toString() ?? '';
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

  static String? _readOrderId(Object? order) {
    if (order is Map && order['id'] != null) return order['id'].toString();
    final value = order?.toString().trim();
    return value == null || value.isEmpty ? null : value;
  }
}
