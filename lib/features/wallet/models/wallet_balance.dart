class WalletBalance {
  final double balance;
  final double pendingBalance;
  final double totalEarned;

  const WalletBalance({
    required this.balance,
    required this.pendingBalance,
    required this.totalEarned,
  });

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    return WalletBalance(
      balance: _readDouble(json, 'balance'),
      pendingBalance: _readDouble(json, 'pendingBalance'),
      totalEarned: _readDouble(json, 'totalEarned'),
    );
  }

  static double _readDouble(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
