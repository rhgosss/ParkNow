import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import '../shared/models/models.dart';

class SpotsDb {
  Future<Database> get _db async => await DatabaseHelper().database;

  Future<void> insertSpot(ParkingSpot spot) async {
    final db = await _db;
    await db.insert(
      'spots',
      spot.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ParkingSpot>> getAllSpots() async {
    final db = await _db;
    final maps = await db.query('spots');
    return maps.map((e) => ParkingSpot.fromMap(e)).toList();
  }

  Future<void> clearAllSpots() async {
    final db = await _db;
    await db.delete('spots');
  }

  Future<void> deleteSpot(String id) async {
    final db = await _db;
    await db.delete('spots', where: 'id = ?', whereArgs: [id]);
  }
}
