import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('yosfe_aqarat.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    // تفعيل مفاتيح الدعم الخارجية Foreign Keys
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
          'ALTER TABLE tenants ADD COLUMN is_active INTEGER DEFAULT 1');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textTypeNull = 'TEXT';
    const boolType = 'INTEGER DEFAULT 0';
    const intType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';

    // 1. جدول العمارات (Buildings)
    await db.execute('''
      CREATE TABLE buildings (
        id $idType,
        name $textType,
        floors_count $intType,
        apartments_count $intType,
        rent_cycle ${textTypeNull} DEFAULT 'شهري',
        auto_name_apartments ${intType} DEFAULT 1,
        created_at $textTypeNull
      )
    ''');

    // 2. جدول الشقق (Apartments)
    await db.execute('''
      CREATE TABLE apartments (
        id $idType,
        building_id $intType,
        name_or_number $textType,
        floor_number $intType,
        is_rented $boolType,
        FOREIGN KEY (building_id) REFERENCES buildings (id) ON DELETE CASCADE
      )
    ''');

    // 3. جدول المستأجرين (Tenants)
    await db.execute('''
      CREATE TABLE tenants (
        id $idType,
        apartment_id $intType,
        name $textType,
        phone $textTypeNull,
        rent_amount $realType,
        contract_image_path $textTypeNull,
        start_date $textTypeNull,
        notes $textTypeNull,
        is_active INTEGER DEFAULT 1,
        FOREIGN KEY (apartment_id) REFERENCES apartments (id) ON DELETE RESTRICT
      )
    ''');

    // 4. جدول المدفوعات (Payments)
    await db.execute('''
      CREATE TABLE payments (
        id $idType,
        tenant_id $intType,
        amount $realType,
        payment_date $textType,
        rent_month $textType,
        payment_method ${textTypeNull} DEFAULT 'نقدي',
        notes $textTypeNull,
        FOREIGN KEY (tenant_id) REFERENCES tenants (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
