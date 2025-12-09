import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/landmark.dart';

class DbService {
  static final DbService _instance = DbService._internal();
  factory DbService() => _instance;
  DbService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'landmarks.db');
    _db = await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE landmarks (
          id INTEGER PRIMARY KEY,
          title TEXT,
          lat REAL,
          lon REAL,
          image TEXT
        )
      ''');
    });
    return _db!;
  }

  Future<void> upsertLandmarks(List<Landmark> list) async {
    final db = await database;
    final batch = db.batch();
    for (var l in list) {
      batch.insert('landmarks', l.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Landmark>> getAll() async {
    final db = await database;
    final rows = await db.query('landmarks');
    return rows.map((r) => Landmark.fromJson(r)).toList();
  }

  Future<void> insert(Landmark l) async {
    final db = await database;
    await db.insert('landmarks', l.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> delete(int id) async {
    final db = await database;
    await db.delete('landmarks', where: 'id = ?', whereArgs: [id]);
  }
}
