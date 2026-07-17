class WalletEarnings {
  final DateTime from;
  final DateTime to;
  final double income;
  final double adjustments;
  final double total;

  const WalletEarnings({
    required this.from,
    required this.to,
    required this.income,
    required this.adjustments,
    required this.total,
  });

  factory WalletEarnings.fromJson(Map<String, dynamic> json) {
    return WalletEarnings(
      from: DateTime.parse(json['from'].toString()).toLocal(),
      to: DateTime.parse(json['to'].toString()).toLocal(),
      income: _readDouble(json['income']),
      adjustments: _readDouble(json['adjustments']),
      total: _readDouble(json['total']),
    );
  }

  static double _readDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class WalletDatePeriod {
  final DateTime from;
  final DateTime toExclusive;

  const WalletDatePeriod({required this.from, required this.toExclusive});

  factory WalletDatePeriod.month(DateTime date) {
    final from = DateTime(date.year, date.month);
    return WalletDatePeriod(
      from: from,
      toExclusive: DateTime(date.year, date.month + 1),
    );
  }

  factory WalletDatePeriod.range(DateTimeRangeValues range) {
    final from = DateTime(range.start.year, range.start.month, range.start.day);
    return WalletDatePeriod(
      from: from,
      toExclusive: DateTime(range.end.year, range.end.month, range.end.day + 1),
    );
  }
}

class DateTimeRangeValues {
  final DateTime start;
  final DateTime end;

  const DateTimeRangeValues({required this.start, required this.end});
}
