
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> initDatabase() async {
  final databasePath = await getDatabasesPath();
  final path = join(databasePath, 'my_database.db');

  return openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE users(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          age INTEGER
        )
      ''');
    },
  );
}

Future<void> insertUser(String name, int age) async {
  final db = await initDatabase();
  await db.insert(
    'users',
    {'name': name, 'age': age},
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<List<Map<String, dynamic>>> getUsers() async {
  final db = await initDatabase();
  return db.query('users');
}

Future<int> updateUser(int id, String newName) async {
  final db = await initDatabase();
  return db.update(
    'users',
    {'name': newName},
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<int> deleteUser(int id) async {
  final db = await initDatabase();
  return db.delete(
    'users',
    where: 'id = ?',
    whereArgs: [id],
  );
}
