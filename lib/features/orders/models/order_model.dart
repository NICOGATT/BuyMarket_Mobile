class OrderModel {
  final String id;
  final String status;
  final double total;
  final DateTime? createdAt;

  OrderModel({
    required this.id,
    required this.status,
    required this.total,
    this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      status: json['status'] ?? 'pending',
      total: double.parse(json['total'].toString()),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }
}