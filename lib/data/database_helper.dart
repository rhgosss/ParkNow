import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'parknow.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Users Table
        await db.execute('''
          CREATE TABLE users (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            email TEXT NOT NULL,
            password TEXT NOT NULL,
            role TEXT NOT NULL
          )
        ''');

        // Parking Spots Table
        await db.execute('''
          CREATE TABLE spots (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            area TEXT NOT NULL,
            rating REAL NOT NULL,
            reviews INTEGER NOT NULL,
            price_per_hour REAL NOT NULL,
            image_url TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL
          )
        ''');
      },
    );
  }
}
