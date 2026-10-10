
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';

class MyOrdersScreen extends StatefulWidget {
const MyOrdersScreen({super.key});

@override
State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
bool _loading = true;
String? _error;
List<Map<String, dynamic>> _orders = [];
final Map<int, List<Map<String, dynamic>>> _itemsByOrder = {};
final Set<int> _expandedOrders = {};

@override
void initState() {
super.initState();
_loadOrders();
}

Future<void> _loadOrders() async {
setState(() {
_loading = true;
_error = null;
});

try {
final userId = await AuthService().currentUserId();

if (userId == null) {
if (!mounted) return;
setState(() {
_orders = [];
_loading = false;
});
return;
}

final db = await DatabaseService.instance.database;

final orders = await db.query(
'orders',
where: 'user_id = ?',
whereArgs: [userId],
orderBy: 'placed_at DESC',
);

if (!mounted) return;

setState(() {
_orders = orders;
_loading = false;
});
} catch (e) {
if (!mounted) return;
setState(() {
_error = 'Could not load your orders. Please try again.';
_loading = false;
});
}
}

Future<void> _toggleOrder(int orderId) async {
if (_expandedOrders.contains(orderId)) {
setState(() => _expandedOrders.remove(orderId));
return;
}

if (!_itemsByOrder.containsKey(orderId)) {
try {
final db = await DatabaseService.instance.database;

final items = await db.query(
'order_items',
where: 'order_id = ?',
whereArgs: [orderId],
orderBy: 'id ASC',
);

if (!mounted) return;

setState(() {
_itemsByOrder[orderId] = items;
_expandedOrders.add(orderId);
});
} catch (e) {
if (!mounted) return;
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('Could not load the items for this order.'),
),
);
}
} else {
setState(() => _expandedOrders.add(orderId));
}
}

String _formatDate(dynamic value) {
if (value == null) return 'Date unavailable';

final parsed = DateTime.tryParse(value.toString());
if (parsed == null) return value.toString();

final date = parsed.toLocal();
final day = date.day.toString().padLeft(2, '0');
final month = date.month.toString().padLeft(2, '0');

return '$day/$month/${date.year}';
}

Color _statusColor(String status) {
switch (status.toLowerCase()) {
case 'delivered':
case 'completed':
return const Color(0xFF2E7D32);
case 'cancelled':
case 'canceled':
return const Color(0xFFA84832);
case 'shipped':
case 'processing':
return const Color(0xFF946D16);
default:
return const Color(0xFF6B6B5F);
}
}

String _money(dynamic value) {
final amount = value is num
? value.toDouble()
    : double.tryParse(value?.toString() ?? '') ?? 0;
return '₦${amount.toStringAsFixed(2)}';
}

@override
Widget build(BuildContext context) {
const forest = Color(0xFF1F3A2E);
const cream = Color(0xFFFAF7F0);
const border = Color(0xFFE5E0D5);

return Scaffold(
backgroundColor: cream,
appBar: AppBar(
title: const Text('My Orders'),
backgroundColor: forest,
foregroundColor: Colors.white,
),
body: _buildBody(forest, border),
);
}

Widget _buildBody(Color forest, Color border) {
if (_loading) {
return const Center(child: CircularProgressIndicator());
}

if (_error != null) {
return Center(
child: Padding(
padding: const EdgeInsets.all(24),
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
const Icon(Icons.error_outline, size: 44),
const SizedBox(height: 12),
Text(_error!, textAlign: TextAlign.center),
const SizedBox(height: 12),
ElevatedButton(
onPressed: _loadOrders,
child: const Text('Try again'),
),
],
),
),
);
}

if (_orders.isEmpty) {
return Center(
child: Padding(
padding: const EdgeInsets.all(28),
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
Icon(Icons.receipt_long_outlined, size: 64, color: forest),
const SizedBox(height: 16),
const Text(
'No orders yet',
style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
),
const SizedBox(height: 8),
const Text(
'Your purchases will appear here after you place an order.',
textAlign: TextAlign.center,
),
const SizedBox(height: 18),
ElevatedButton(
style: ElevatedButton.styleFrom(
backgroundColor: forest,
foregroundColor: Colors.white,
),
onPressed: () {
Navigator.pushNamedAndRemoveUntil(
context,
'/home',
(route) => false,
);
},
child: const Text('Continue shopping'),
),
],
),
),
);
}

return RefreshIndicator(
onRefresh: _loadOrders,
child: ListView(
padding: const EdgeInsets.all(16),
children: [
Text(
'${_orders.length} ${_orders.length == 1 ? 'order' : 'orders'}',
style: TextStyle(
color: forest,
fontSize: 18,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 12),
for (final order in _orders)
_buildOrderCard(order, forest, border),
],
),
);
}

Widget _buildOrderCard(
Map<String, dynamic> order,
Color forest,
Color border,
) {
final orderId = order['id'] as int;
final status = (order['status'] ?? 'Pending').toString();
final expanded = _expandedOrders.contains(orderId);
final items = _itemsByOrder[orderId] ?? [];

return Card(
margin: const EdgeInsets.only(bottom: 14),
elevation: 0,
color: Colors.white,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(16),
side: BorderSide(color: border),
),
child: Padding(
padding: const EdgeInsets.all(16),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Icon(Icons.receipt_long, color: forest, size: 28),
const SizedBox(width: 10),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
order['order_number']?.toString() ??
'Order #$orderId',
style: TextStyle(
color: forest,
fontWeight: FontWeight.bold,
fontSize: 16,
),
),
const SizedBox(height: 4),
Text(
'Placed ${_formatDate(order['placed_at'])}',
style: const TextStyle(color: Color(0xFF6B6B5F)),
),
],
),
),
Container(
padding: const EdgeInsets.symmetric(
horizontal: 10,
vertical: 6,
),
decoration: BoxDecoration(
color: _statusColor(status).withValues(alpha: 0.12),
borderRadius: BorderRadius.circular(20),
),
child: Text(
status,
style: TextStyle(
color: _statusColor(status),
fontWeight: FontWeight.w600,
fontSize: 12,
),
),
),
],
),
const SizedBox(height: 16),
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
const Text('Order total'),
Text(
_money(order['total']),
style: TextStyle(
color: forest,
fontWeight: FontWeight.bold,
fontSize: 17,
),
),
],
),
const SizedBox(height: 12),
SizedBox(
width: double.infinity,
child: OutlinedButton.icon(
onPressed: () => _toggleOrder(orderId),
icon: Icon(
expanded ? Icons.expand_less : Icons.expand_more,
),
label: Text(
expanded ? 'Hide order details' : 'View order details',
),
),
),
if (expanded) ...[
const Divider(height: 24),
const Text(
'Items',
style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
),
const SizedBox(height: 8),
if (items.isEmpty)
const Text('No items were found for this order.')
else
for (final item in items)
Padding(
padding: const EdgeInsets.symmetric(vertical: 7),
child: Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Icon(Icons.menu_book_outlined, color: forest),
const SizedBox(width: 10),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
item['title']?.toString() ?? 'Untitled book',
style: const TextStyle(
fontWeight: FontWeight.w600,
),
),
Text(
'${item['author'] ?? 'Unknown author'} · Qty ${item['quantity'] ?? 1}',
style: const TextStyle(
color: Color(0xFF6B6B5F),
fontSize: 12,
),
),
],
),
),
Text(_money(item['price'])),
],
),
),
const Divider(height: 24),
const Text(
'Shipping address',
style: TextStyle(fontWeight: FontWeight.bold),
),
const SizedBox(height: 5),
Text(
order['shipping_address']?.toString() ??
'Address unavailable',
),
const SizedBox(height: 12),
const Text(
'Payment method',
style: TextStyle(fontWeight: FontWeight.bold),
),
const SizedBox(height: 5),
Text(
order['payment_method']?.toString() ??
'Payment method unavailable',
),
],
],
),
),
);
}
}
