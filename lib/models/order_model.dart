class OrderModel {
  final int? id;
  final int userId;
  final String orderNumber;
  final String status;
  final double subtotal;
  final double shipping;
  final double total;
  final String shippingAddress;
  final String paymentMethod;
  final String placedAt;

  const OrderModel({
    this.id,
    required this.userId,
    required this.orderNumber,
    this.status = 'Pending',
    required this.subtotal,
    required this.shipping,
    required this.total,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.placedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'user_id': userId,
    'order_number': orderNumber,
    'status': status,
    'subtotal': subtotal,
    'shipping': shipping,
    'total': total,
    'shipping_address': shippingAddress,
    'payment_method': paymentMethod,
    'placed_at': placedAt,
  };

  factory OrderModel.fromMap(Map<String, dynamic> row) => OrderModel(
    id: row['id'] as int?,
    userId: row['user_id'] as int,
    orderNumber: row['order_number'] as String,
    status: row['status'] as String,
    subtotal: (row['subtotal'] as num).toDouble(),
    shipping: (row['shipping'] as num).toDouble(),
    total: (row['total'] as num).toDouble(),
    shippingAddress: row['shipping_address'] as String,
    paymentMethod: row['payment_method'] as String,
    placedAt: row['placed_at'] as String,
  );
}
