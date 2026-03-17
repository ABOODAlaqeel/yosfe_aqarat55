import '../../models/building_model.dart';
import '../../core/database/database_helper.dart';

class BuildingRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<int> insertBuilding(Building building) async {
    final db = await dbHelper.database;
    return await db.insert('buildings', building.toMap());
  }

  Future<List<Building>> getAllBuildings() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps =
        await db.query('buildings', orderBy: 'id DESC');

    return List.generate(maps.length, (i) {
      return Building.fromMap(maps[i]);
    });
  }

  Future<int> updateBuilding(Building building) async {
    final db = await dbHelper.database;
    return await db.update(
      'buildings',
      building.toMap(),
      where: 'id = ?',
      whereArgs: [building.id],
    );
  }

  Future<int> deleteBuilding(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'buildings',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
