
import 'package:flutter/material.dart';

import '../../services/database_service.dart';

class ManageOrdersScreen extends StatefulWidget {
const ManageOrdersScreen({super.key});

@override
State<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen> {
static const Color _forest = Color(0xFF1F3A2E);
static const Color _cream = Color(0xFFFAF7F0);
static const Color _gold = Color(0xFFC9A961);
static const Color _muted = Color(0xFF6B6B5F);

final List<String> _statuses = const [
'Pending',
'Processing',
'Shipped',
'Delivered',
'Cancelled',
];

List<Map<String, Object?>> _orders = [];
Map<int, String> _customerNames = {};

bool _loading = true;
String? _error;
String _filter = 'All';

@override
void initState() {
super.initState();
_loadOrders();
}

Future<void> _loadOrders() async {
if (!mounted) return;

setState(() {
_loading = true;
_error = null;
});

try {
final db = await DatabaseService.instance.database;

final orderRows = await db.query(
'orders',
orderBy: 'id DESC',
);

final userRows = await db.query('users');
final customerNames = <int, String>{};

for (final user in userRows) {
final id = user['id'];
final name = user['name'];

if (id is int && name is String) {
customerNames[id] = name;
}
}

if (!mounted) return;

setState(() {
_orders = orderRows;
_customerNames = customerNames;
_loading = false;
});
} catch (error, stackTrace) {
debugPrint('Loading orders failed: $error');
debugPrintStack(stackTrace: stackTrace);

if (!mounted) return;

setState(() {
_error = 'Could not load orders. Please try again.';
_loading = false;
});
}
}

List<Map<String, Object?>> get _filteredOrders {
if (_filter == 'All') return _orders;

return _orders.where((order) {
return (order['status']?.toString() ?? 'Pending').toLowerCase() ==
_filter.toLowerCase();
}).toList();
}

Future<void> _updateStatus(
Map<String, Object?> order,
String newStatus,
) async {
final orderId = order['id'];

if (orderId is! int) {
_showMessage('This order has an invalid ID.');
return;
}

final oldStatus = order['status']?.toString() ?? 'Pending';

if (oldStatus == newStatus) return;

try {
final db = await DatabaseService.instance.database;

final updated = await db.update(
'orders',
{'status': newStatus},
where: 'id = ?',
whereArgs: [orderId],
);

if (!mounted) return;

if (updated == 0) {
_showMessage('Order was not found.');
await _loadOrders();
return;
}

setState(() {
final index =
_orders.indexWhere((item) => item['id'] == orderId);

if (index != -1) {
_orders[index] = {
..._orders[index],
'status': newStatus,
};
}
});

_showMessage('Order #$orderId updated to $newStatus.');
} catch (error, stackTrace) {
debugPrint('Order status update failed: $error');
debugPrintStack(stackTrace: stackTrace);

if (!mounted) return;

_showMessage('Update failed: $error');
}
}

void _showMessage(String message) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(message),
duration: const Duration(seconds: 5),
),
);
}

Color _statusColor(String status) {
switch (status.toLowerCase()) {
case 'delivered':
return const Color(0xFF2E7D32);
case 'shipped':
return const Color(0xFF1565C0);
case 'processing':
return const Color(0xFF9A6A13);
case 'cancelled':
return const Color(0xFFA84832);
default:
return _muted;
}
}

String _customerName(Map<String, Object?> order) {
final userId = order['user_id'];

if (userId is int) {
return _customerNames[userId] ?? 'Unknown customer';
}

return 'Unknown customer';
}

String _formatDate(Object? value) {
if (value == null) return 'Date unavailable';

final parsed = DateTime.tryParse(value.toString());

if (parsed == null) return value.toString();

final date = parsed.toLocal();

return '${date.day.toString().padLeft(2, '0')}/'
'${date.month.toString().padLeft(2, '0')}/${date.year}';
}

@override
Widget build(BuildContext context) {
final orders = _filteredOrders;

return Scaffold(
backgroundColor: _cream,
body: SafeArea(
child: RefreshIndicator(
color: _forest,
onRefresh: _loadOrders,
child: ListView(
padding: const EdgeInsets.all(20),
children: [
const Text(
'Manage Orders',
style: TextStyle(
color: _forest,
fontSize: 27,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 6),
const Text(
'Review purchases and keep order statuses up to date.',
style: TextStyle(color: _muted, fontSize: 14),
),
const SizedBox(height: 22),
_buildSummary(),
const SizedBox(height: 22),
const Text(
'Filter by status',
style: TextStyle(
color: _forest,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 10),
DropdownButtonFormField<String>(
initialValue: _filter,
decoration: InputDecoration(
filled: true,
fillColor: Colors.white,
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(12),
),
enabledBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(12),
borderSide: const BorderSide(
color: Color(0xFFE5E0D5),
),
),
),
items: ['All', ..._statuses].map((status) {
return DropdownMenuItem<String>(
value: status,
child: Text(status),
);
}).toList(),
onChanged: (value) {
if (value != null) {
setState(() => _filter = value);
}
},
),
const SizedBox(height: 22),
Row(
children: [
const Expanded(
child: Text(
'Orders',
style: TextStyle(
color: _forest,
fontSize: 19,
fontWeight: FontWeight.bold,
),
),
),
Text(
'${orders.length} found',
style: const TextStyle(color: _muted),
),
],
),
const SizedBox(height: 12),
if (_loading)
const Padding(
padding: EdgeInsets.all(40),
child: Center(
child: CircularProgressIndicator(color: _forest),
),
)
else if (_error != null)
_buildMessage(
icon: Icons.error_outline,
message: _error!,
buttonText: 'Try again',
onPressed: _loadOrders,
)
else if (orders.isEmpty)
_buildMessage(
icon: Icons.receipt_long_outlined,
message: _orders.isEmpty
? 'No orders have been placed yet.'
    : 'No orders match this status.',
buttonText: _orders.isEmpty ? 'Refresh' : 'Show all',
onPressed: _orders.isEmpty
? _loadOrders
    : () => setState(() => _filter = 'All'),
)
else
...orders.map(_buildOrderCard),
],
),
),
),
);
}

Widget _buildSummary() {
final pending = _orders.where((order) {
return (order['status']?.toString() ?? 'Pending').toLowerCase() ==
'pending';
}).length;

final delivered = _orders.where((order) {
return (order['status']?.toString() ?? '').toLowerCase() ==
'delivered';
}).length;

return Container(
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
color: _forest,
borderRadius: BorderRadius.circular(18),
),
child: Row(
children: [
Expanded(
child: _summaryItem('Total orders', _orders.length.toString()),
),
Container(
width: 1,
height: 48,
color: Colors.white24,
),
Expanded(
child: _summaryItem('Pending', pending.toString()),
),
Container(
width: 1,
height: 48,
color: Colors.white24,
),
Expanded(
child: _summaryItem('Delivered', delivered.toString()),
),
],
),
);
}

Widget _summaryItem(String label, String value) {
return Column(
children: [
Text(
value,
style: const TextStyle(
color: _gold,
fontSize: 24,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 5),
Text(
label,
textAlign: TextAlign.center,
style: const TextStyle(color: Colors.white70, fontSize: 11),
),
],
);
}

Widget _buildOrderCard(Map<String, Object?> order) {
final orderId = order['id'];
final status = order['status']?.toString() ?? 'Pending';
final total = order['total'];
final placedAt = order['placed_at'];

return Container(
margin: const EdgeInsets.only(bottom: 14),
padding: const EdgeInsets.all(17),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(16),
border: Border.all(color: const Color(0xFFE5E0D5)),
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
children: [
const Icon(
Icons.receipt_long_outlined,
color: _forest,
size: 23,
),
const SizedBox(width: 9),
Expanded(
child: Text(
'Order #${orderId ?? 'N/A'}',
style: const TextStyle(
color: _forest,
fontSize: 17,
fontWeight: FontWeight.bold,
),
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
fontWeight: FontWeight.bold,
fontSize: 11,
),
),
),
],
),
const SizedBox(height: 16),
_detailRow(Icons.person_outline, _customerName(order)),
const SizedBox(height: 9),
_detailRow(
Icons.calendar_today_outlined,
_formatDate(placedAt),
),
const SizedBox(height: 9),
_detailRow(
Icons.payments_outlined,
'Total: ${total == null ? 'Unavailable' : '₦${total.toString()}'}',
),
const SizedBox(height: 18),
const Text(
'Update status',
style: TextStyle(
color: _muted,
fontSize: 12,
fontWeight: FontWeight.w600,
),
),
const SizedBox(height: 8),
DropdownButtonFormField<String>(
initialValue: _statuses.contains(status) ? status : 'Pending',
decoration: InputDecoration(
filled: true,
fillColor: _cream,
contentPadding: const EdgeInsets.symmetric(
horizontal: 12,
vertical: 10,
),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(10),
borderSide: const BorderSide(color: Color(0xFFE5E0D5)),
),
enabledBorder: OutlineInputBorder(
borderRadius: BorderRadius.circular(10),
borderSide: const BorderSide(color: Color(0xFFE5E0D5)),
),
),
items: _statuses.map((item) {
return DropdownMenuItem<String>(
value: item,
child: Text(item),
);
}).toList(),
onChanged: (value) {
if (value != null) {
_updateStatus(order, value);
}
},
),
],
),
);
}

Widget _detailRow(IconData icon, String text) {
return Row(
children: [
Icon(icon, size: 17, color: _muted),
const SizedBox(width: 9),
Expanded(
child: Text(
text,
style: const TextStyle(color: _muted, fontSize: 13),
),
),
],
);
}

Widget _buildMessage({
required IconData icon,
required String message,
required String buttonText,
required VoidCallback onPressed,
}) {
return Padding(
padding: const EdgeInsets.symmetric(vertical: 35),
child: Column(
children: [
Icon(icon, size: 42, color: _muted),
const SizedBox(height: 12),
Text(
message,
textAlign: TextAlign.center,
style: const TextStyle(color: _muted),
),
const SizedBox(height: 16),
OutlinedButton(
onPressed: onPressed,
style: OutlinedButton.styleFrom(
foregroundColor: _forest,
side: const BorderSide(color: _forest),
),
child: Text(buttonText),
),
],
),
);
}
}
