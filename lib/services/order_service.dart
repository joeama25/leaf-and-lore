import '../models/order_item_model.dart';
import '../models/order_model.dart';
import 'database_service.dart';

/// SQLite order records for the currently installed copy of Leaf & Lore.
/// This class does not charge cards, arrange shipping, or provide live tracking.
class OrderService {
  static final OrderService instance = OrderService._internal();
  OrderService._internal();

  static const statuses = <String>[
    'Pending',
    'Processing',
    'Shipped',
    'Out for Delivery',
    'Delivered',
  ];

  Future<List<OrderModel>> getForUser(int userId) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'orders',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'placed_at DESC, id DESC',
    );
    return rows.map(OrderModel.fromMap).toList();
  }

  Future<OrderModel?> getById(int orderId, int userId) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'orders',
      where: 'id = ? AND user_id = ?',
      whereArgs: [orderId, userId],
      limit: 1,
    );
    return rows.isEmpty ? null : OrderModel.fromMap(rows.first);
  }

  /// Only retrieves lines for an order owned by this user.
  Future<List<OrderItemModel>> getItemsForOrder(
    int orderId, int userId,
  ) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.rawQuery('''
      SELECT i.* FROM order_items i
      INNER JOIN orders o ON o.id = i.order_id
      WHERE i.order_id = ? AND o.user_id = ?
      ORDER BY i.id ASC
    ''', [orderId, userId]);
    return rows.map(OrderItemModel.fromMap).toList();
  }

  /// Fetch all the signed-in user's order lines for history thumbnails/counts.
  Future<List<OrderItemModel>> getItemsForUser(int userId) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.rawQuery('''
      SELECT i.* FROM order_items i
      INNER JOIN orders o ON o.id = i.order_id
      WHERE o.user_id = ?
      ORDER BY i.order_id DESC, i.id ASC
    ''', [userId]);
    return rows.map(OrderItemModel.fromMap).toList();
  }

  /// Called by checkout code once an order is ready to be recorded.
  /// Persists the header and items atomically; no payment is taken here.
  Future<int> add(
    OrderModel order, {
    required List<OrderItemModel> items,
  }) async {
    if (items.isEmpty) {
      throw ArgumentError('An order must contain at least one book.');
    }
    if (order.userId < 1 ||
        order.shippingAddress.trim().isEmpty ||
        order.paymentMethod.trim().isEmpty ||
        order.shipping < 0 ||
        !order.shipping.isFinite) {
      throw ArgumentError('Invalid customer, shipping, or payment details.');
    }
    if (!statuses.contains(order.status)) {
      throw ArgumentError.value(order.status, 'status', 'Unknown order status');
    }
    for (final item in items) {
      if (item.bookId < 1 || item.quantity < 1 ||
          item.price < 0 || !item.price.isFinite) {
        throw ArgumentError('Invalid book, quantity or price in order.');
      }
    }
    final subtotal = items.fold<double>(0, (sum, item) => sum + item.lineTotal);
    final total = subtotal + order.shipping;
    if ((order.subtotal - subtotal).abs() > 0.01 ||
        (order.total - total).abs() > 0.01) {
      throw ArgumentError('Order total does not match its items.');
    }
    final db = await DatabaseService.instance.database;
    return db.transaction((txn) async {
      final orderRow = order.toMap()..remove('id');
      final orderId = await txn.insert('orders', orderRow);
      for (final item in items) {
        final row = item.toMap()
          ..remove('id')
          ..['order_id'] = orderId;
        await txn.insert('order_items', row);
      }
      return orderId;
    });
  }

  /// Intended for the part of the application responsible for fulfilment.
  Future<void> updateStatus(int orderId, String status) async {
    if (!statuses.contains(status)) {
      throw ArgumentError.value(status, 'status', 'Unknown order status');
    }
    final db = await DatabaseService.instance.database;
    final count = await db.update(
      'orders',
      {'status': status},
      where: 'id = ?',
      whereArgs: [orderId],
    );
    if (count == 0) throw StateError('Order not found.');
  }
}
