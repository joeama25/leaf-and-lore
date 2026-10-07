import '../models/address_model.dart';
import 'database_service.dart';

class AddressService {
  static final AddressService instance = AddressService._internal();
  AddressService._internal();

  Future<List<AddressModel>> getForUser(int userId) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'addresses',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
    return rows.map((r) => AddressModel.fromMap(r)).toList();
  }

  Future<int> add(AddressModel address) async {
    final db = await DatabaseService.instance.database;
    return db.insert('addresses', address.toMap());
  }

  Future<void> update(AddressModel address) async {
    final db = await DatabaseService.instance.database;
    await db.update(
      'addresses',
      address.toMap(),
      where: 'id = ?',
      whereArgs: [address.id],
    );
  }

  Future<void> remove(int id) async {
    final db = await DatabaseService.instance.database;
    await db.delete('addresses', where: 'id = ?', whereArgs: [id]);
  }
}