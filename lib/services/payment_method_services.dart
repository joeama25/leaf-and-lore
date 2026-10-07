import '../models/payment_method_model.dart';
import 'database_service.dart';

class PaymentMethodService {
  static final PaymentMethodService instance = PaymentMethodService._internal();
  PaymentMethodService._internal();

  Future<List<PaymentMethodModel>> getForUser(int userId) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'payment_methods',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
    return rows.map((r) => PaymentMethodModel.fromMap(r)).toList();
  }

  Future<int> add(PaymentMethodModel pm) async {
    final db = await DatabaseService.instance.database;
    return db.insert('payment_methods', pm.toMap());
  }

  Future<void> remove(int id) async {
    final db = await DatabaseService.instance.database;
    await db.delete(
      'payment_methods',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}