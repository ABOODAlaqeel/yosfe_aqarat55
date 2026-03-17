import '../../models/tenant_model.dart';
import '../../core/database/database_helper.dart';

class TenantRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<int> insertTenant(Tenant tenant) async {
    final db = await dbHelper.database;
    return await db.insert('tenants', tenant.toMap());
  }

  Future<List<Tenant>> getAllTenants() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tenants',
      where: 'is_active = 1',
      orderBy: 'id DESC',
    );

    return List.generate(maps.length, (i) {
      return Tenant.fromMap(maps[i]);
    });
  }

  Future<Tenant?> getTenantById(int id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tenants',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Tenant.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Tenant>> getTenantsByApartments(List<int> apartmentIds) async {
    if (apartmentIds.isEmpty) return [];

    final db = await dbHelper.database;
    final placeholders = List.filled(apartmentIds.length, '?').join(',');
    final List<Map<String, dynamic>> maps = await db.query(
      'tenants',
      where: 'apartment_id IN ($placeholders) AND is_active = 1',
      whereArgs: apartmentIds,
    );

    return List.generate(maps.length, (i) {
      return Tenant.fromMap(maps[i]);
    });
  }

  Future<int> updateTenant(Tenant tenant) async {
    final db = await dbHelper.database;
    return await db.update(
      'tenants',
      tenant.toMap(),
      where: 'id = ?',
      whereArgs: [tenant.id],
    );
  }

  Future<int> deleteTenant(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'tenants',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
