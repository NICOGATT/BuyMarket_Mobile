class WalletSaleDeduction {
  final String code;
  final String label;
  final double amount;

  const WalletSaleDeduction({
    required this.code,
    required this.label,
    required this.amount,
  });

  factory WalletSaleDeduction.fromJson(Map<String, dynamic> json) {
    return WalletSaleDeduction(
      code: json['code']?.toString() ?? '',
      label: json['label']?.toString() ?? 'Descuento',
      amount: _readDouble(json['amount']),
    );
  }
}

class WalletSale {
  final String id;
  final String orderId;
  final String productTitle;
  final String? variantSize;
  final String? variantColor;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final DateTime? createdAt;
  final double grossAmount;
  final List<WalletSaleDeduction> deductions;
  final double netAmount;
  final String walletStatus;
  final DateTime? effectiveAt;

  const WalletSale({
    required this.id,
    required this.orderId,
    required this.productTitle,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    required this.grossAmount,
    required this.deductions,
    required this.netAmount,
    required this.walletStatus,
    this.variantSize,
    this.variantColor,
    this.createdAt,
    this.effectiveAt,
  });

  bool get isAccredited => walletStatus.toLowerCase() == 'completed';

  String get variantLabel {
    return [
      if (variantSize != null && variantSize!.isNotEmpty) 'Talle $variantSize',
      if (variantColor != null && variantColor!.isNotEmpty) variantColor!,
    ].join(' · ');
  }

  factory WalletSale.fromJson(Map<String, dynamic> json) {
    final product = _readMap(json['product']);
    final variant = _readMap(json['variant']);
    final financial = _readMap(json['financial']);
    final deductionsData = financial['deductions'];

    return WalletSale(
      id: json['saleId']?.toString() ?? json['orderItemId']?.toString() ?? '',
      orderId: json['orderId']?.toString() ?? '',
      productTitle: product['title']?.toString() ?? 'Producto',
      variantSize: _readNullableString(variant['size']),
      variantColor: _readNullableString(variant['color']),
      quantity: int.tryParse(json['quantity']?.toString() ?? '') ?? 0,
      unitPrice: _readDouble(json['unitPrice']),
      subtotal: _readDouble(json['subtotal']),
      createdAt: _readDate(json['createdAt']),
      grossAmount: _readDouble(financial['grossAmount']),
      deductions: deductionsData is List
          ? deductionsData
                .whereType<Map>()
                .map(
                  (item) => WalletSaleDeduction.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList(growable: false)
          : const [],
      netAmount: _readDouble(financial['netAmount']),
      walletStatus: financial['walletStatus']?.toString() ?? 'unavailable',
      effectiveAt: _readDate(financial['effectiveAt']),
    );
  }
}

Map<String, dynamic> _readMap(Object? value) {
  return value is Map ? Map<String, dynamic>.from(value) : const {};
}

String? _readNullableString(Object? value) {
  final normalized = value?.toString().trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}

double _readDouble(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime? _readDate(Object? value) {
  final normalized = value?.toString();
  if (normalized == null || normalized.isEmpty) return null;
  return DateTime.tryParse(normalized)?.toLocal();
}
