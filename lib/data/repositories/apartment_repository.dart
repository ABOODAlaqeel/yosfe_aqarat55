import 'package:sqflite/sqflite.dart';
import '../../models/apartment_model.dart';
import '../../core/database/database_helper.dart';

class ApartmentRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<int> insertApartment(Apartment apartment) async {
    final db = await dbHelper.database;
    return await db.insert('apartments', apartment.toMap());
  }

  Future<void> insertApartmentsBatch(List<Apartment> apartments) async {
    final db = await dbHelper.database;
    Batch batch = db.batch();
    for (var apartment in apartments) {
      batch.insert('apartments', apartment.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<List<Apartment>> getApartmentsForBuilding(int buildingId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'apartments',
      where: 'building_id = ?',
      whereArgs: [buildingId],
      orderBy: 'floor_number ASC, name_or_number ASC',
    );

    return List.generate(maps.length, (i) {
      return Apartment.fromMap(maps[i]);
    });
  }

  Future<int> updateApartment(Apartment apartment) async {
    final db = await dbHelper.database;
    return await db.update(
      'apartments',
      apartment.toMap(),
      where: 'id = ?',
      whereArgs: [apartment.id],
    );
  }
}
