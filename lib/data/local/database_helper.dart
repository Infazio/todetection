// File: lib/data/local/database_helper.dart
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import '../models/person_model.dart';

class DatabaseHelper {
  static const _databaseName = "FaceRecognitionDB.db";
  static const _databaseVersion = 1;

  // Table and column names
  static const _tableName = 'persons';
  static const _columnId = 'id';
  static const _columnName = 'name';
  static const _columnEmbedding = 'embedding';
  static const _columnThumbnailPath = 'thumbnail_path';
  static const _columnCreatedAt = 'created_at';
  static const _columnUpdatedAt = 'updated_at';
  static const _columnConfidenceThreshold = 'confidence_threshold';

  // Singleton pattern
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize database
  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // Create table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        $_columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $_columnName TEXT NOT NULL,
        $_columnEmbedding TEXT NOT NULL,
        $_columnThumbnailPath TEXT,
        $_columnCreatedAt TEXT NOT NULL,
        $_columnUpdatedAt TEXT NOT NULL,
        $_columnConfidenceThreshold REAL DEFAULT 0.7
      )
    ''');

    print("Database table '$_tableName' created successfully");
  }

  // Insert person
  Future<int> insertPerson(Person person) async {
    final db = await database;
    final id = await db.insert(_tableName, person.toMap());
    print("Person inserted with ID: $id");
    return id;
  }

  // Get all persons
  Future<List<Person>> getAllPersons() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableName);

    return List.generate(maps.length, (i) {
      return Person.fromMap(maps[i]);
    });
  }

  // Get person by ID
  Future<Person?> getPersonById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: '$_columnId = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Person.fromMap(maps.first);
    }
    return null;
  }

  // Search persons by name
  Future<List<Person>> searchPersonsByName(String name) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: '$_columnName LIKE ?',
      whereArgs: ['%$name%'],
    );

    return List.generate(maps.length, (i) {
      return Person.fromMap(maps[i]);
    });
  }

  // Update person
  Future<int> updatePerson(Person person) async {
    final db = await database;
    return await db.update(
      _tableName,
      person.toMap(),
      where: '$_columnId = ?',
      whereArgs: [person.id],
    );
  }

  // Delete person
  Future<int> deletePerson(int id) async {
    final db = await database;
    return await db.delete(
      _tableName,
      where: '$_columnId = ?',
      whereArgs: [id],
    );
  }

  // Get total count
  Future<int> getPersonCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM $_tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Clear all data (for testing)
  Future<void> clearAllPersons() async {
    final db = await database;
    await db.delete(_tableName);
    print("All persons cleared from database");
  }

  // Close database
  Future close() async {
    final db = await database;
    db.close();
  }
}
