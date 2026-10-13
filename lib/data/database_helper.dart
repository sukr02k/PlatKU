import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._();

  static DatabaseHelper getInstance() {
    _instance ??= DatabaseHelper._();
    return _instance!;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'kendaraanku.db');
    return openDatabase(
      path,
      version: 3,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(_createVehicleDocumentsSql);
    }
    if (oldVersion < 3) {
      await _createIndexes(db);
    }
  }

  Future<void> _createIndexes(Database db) async {
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_vehicles_user_active ON vehicles(user_id, is_active)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_fuel_logs_vehicle_date ON fuel_logs(vehicle_id, date DESC)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_service_logs_vehicle_date ON service_logs(vehicle_id, date DESC)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_vehicle_documents_vehicle_expiry ON vehicle_documents(vehicle_id, expiry_date)',
    );
  }

  static const String _createVehicleDocumentsSql = '''
    CREATE TABLE vehicle_documents (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      vehicle_id INTEGER NOT NULL,
      document_type TEXT NOT NULL,
      document_number TEXT,
      issue_date TEXT,
      expiry_date TEXT,
      image_path TEXT,
      notes TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE
    )
  ''';

  Future<void> _onCreate(Database db, int version) async {
    // Users table (local auth)
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        image_path TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Vehicles table
    await db.execute('''
      CREATE TABLE vehicles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        brand TEXT NOT NULL,
        model TEXT NOT NULL,
        year INTEGER NOT NULL,
        plate_number TEXT NOT NULL,
        color TEXT NOT NULL,
        image_path TEXT,
        initial_odometer REAL NOT NULL DEFAULT 0,
        fuel_type TEXT NOT NULL DEFAULT 'Pertalite',
        tank_capacity REAL,
        is_active INTEGER NOT NULL DEFAULT 1,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Fuel logs table
    await db.execute('''
      CREATE TABLE fuel_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicle_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        odometer REAL NOT NULL,
        liters REAL NOT NULL,
        price_per_liter REAL NOT NULL,
        total_cost REAL NOT NULL,
        fuel_type TEXT NOT NULL,
        station_name TEXT,
        is_full_tank INTEGER NOT NULL DEFAULT 1,
        receipt_image_path TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE
      )
    ''');

    // Service logs table
    await db.execute('''
      CREATE TABLE service_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicle_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        odometer REAL,
        service_type TEXT NOT NULL,
        description TEXT NOT NULL,
        cost REAL NOT NULL,
        workshop_name TEXT,
        receipt_image_path TEXT,
        next_service_odometer REAL,
        next_service_date TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE
      )
    ''');

    // Vehicle documents table (STNK, BPKB, SIM, Asuransi, Pajak)
    await db.execute(_createVehicleDocumentsSql);

    // Expense categories table
    await db.execute('''
      CREATE TABLE expense_categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        is_default INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // B-Tree Indexes
    await _createIndexes(db);

    // Seed default expense categories
    final defaultCategories = [
      {'name': 'Ganti Oli Mesin', 'icon': 'oil_barrel'},
      {'name': 'Ganti Oli Gardan', 'icon': 'oil_barrel'},
      {'name': 'Ganti Ban', 'icon': 'tire_repair'},
      {'name': 'Tune Up / Servis Rutin', 'icon': 'build'},
      {'name': 'Ganti Aki', 'icon': 'battery_charging_full'},
      {'name': 'Ganti Kampas Rem', 'icon': 'disc_full'},
      {'name': 'Ganti V-Belt', 'icon': 'settings'},
      {'name': 'Servis AC', 'icon': 'ac_unit'},
      {'name': 'Perpanjang STNK / Pajak', 'icon': 'description'},
      {'name': 'Lain-lain', 'icon': 'more_horiz'},
    ];

    for (final cat in defaultCategories) {
      await db.insert('expense_categories', {
        ...cat,
        'is_default': 1,
      });
    }
  }

  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }
}
