import '../../models/payment_model.dart';
import '../../core/database/database_helper.dart';

class PaymentRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<int> insertPayment(Payment payment) async {
    final db = await dbHelper.database;
    return await db.insert('payments', payment.toMap());
  }

  Future<List<Payment>> getAllPayments() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps =
        await db.query('payments', orderBy: 'id DESC');

    return List.generate(maps.length, (i) {
      return Payment.fromMap(maps[i]);
    });
  }

  Future<List<Payment>> getPaymentsByTenant(int tenantId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'payments',
      where: 'tenant_id = ?',
      whereArgs: [tenantId],
      orderBy: 'id DESC', // أحدث عمليات الدفع أولاً
    );

    return List.generate(maps.length, (i) {
      return Payment.fromMap(maps[i]);
    });
  }

  Future<List<Payment>> getPaymentsByTenants(List<int> tenantIds) async {
    if (tenantIds.isEmpty) return [];

    final db = await dbHelper.database;
    final placeholders = List.filled(tenantIds.length, '?').join(',');
    final List<Map<String, dynamic>> maps = await db.query(
      'payments',
      where: 'tenant_id IN ($placeholders)',
      whereArgs: tenantIds,
    );

    return List.generate(maps.length, (i) {
      return Payment.fromMap(maps[i]);
    });
  }

  Future<int> deletePayment(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'payments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
