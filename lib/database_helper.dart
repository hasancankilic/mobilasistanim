import 'package:path/path.dart';
import 'package:proje_ilk/model/task.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      String path = join(await getDatabasesPath(), 'tasks_database.db');
      return await openDatabase(path, version: 2, onCreate: _createDatabase, onUpgrade: _onUpgrade);
    } catch (e) {
      print("Veritabanı oluşturulurken bir hata oluştu: $e");
      rethrow;
    }
  }

  Future<void> _createDatabase(Database db, int version) async {
    try {
      await db.execute('''
    CREATE TABLE tasks(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      description TEXT,
      is_completed INTEGER,
      type TEXT,
      username TEXT,
      date_time TEXT
    )
  ''');
      await db.execute('''
    CREATE TABLE users(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT UNIQUE,
      password TEXT
    )
  ''');
    } catch (e) {
      print("Veritabanı oluşturulurken bir hata oluştu: $e");
      rethrow;
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE tasks ADD COLUMN date_time TEXT');
    }
  }

  Future<int> insertTask(Task task) async {
    Database db = await instance.database;
    try {
      return await db.insert('tasks', task.toMap());
    } catch (e) {
      print("Görev eklenirken bir hata oluştu: $e");
      rethrow;
    }
  }

  Future<int> updateTask(Task task) async {
    Database db = await instance.database;
    try {
      return await db.update(
        'tasks',
        task.toMap(),
        where: 'id = ?',
        whereArgs: [task.id],
      );
    } catch (e) {
      print("Görev güncellenirken bir hata oluştu: $e");
      rethrow;
    }
  }

  Future<void> deleteTask(int id) async {
    Database db = await instance.database;
    try {
      await db.delete(
        'tasks',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print("Görev silinirken bir hata oluştu: $e");
      rethrow;
    }
  }

  Future<List<Task>> getAllTasks() async {
    try {
      Database db = await instance.database;
      List<Map<String, dynamic>> maps = await db.query('tasks');
      return List.generate(maps.length, (index) => Task.fromMap(maps[index]));
    } catch (e) {
      print("Görevleri alırken bir hata oluştu: $e");
      rethrow;
    }
  }

  Future<List<Task>> getAllCompletedTasks() async {
    try {
      Database db = await instance.database;
      List<Map<String, dynamic>> maps = await db.query(
        'tasks',
        where: 'is_completed = ?',
        whereArgs: [1],
      );
      return List.generate(maps.length, (index) => Task.fromMap(maps[index]));
    } catch (e) {
      print("Tamamlanan görevleri alırken bir hata oluştu: $e");
      rethrow;
    }
  }

  Future<int> addCompletedTask(Task task) async {
    try {
      Database db = await instance.database;
      return await db.insert('tasks', task.toMap());
    } catch (e) {
      print("Tamamlanan görev eklenirken bir hata oluştu: $e");
      rethrow;
    }
  }

  Future<int> deleteCompletedTask(Task task) async {
    try {
      Database db = await instance.database;
      return await db.delete(
        'tasks',
        where: 'id = ?',
        whereArgs: [task.id],
      );
    } catch (e) {
      print("Tamamlanan görev silinirken bir hata oluştu: $e");
      rethrow;
    }
  }

  Future<int> insertUser(String username, String password) async {
    try {
      Database db = await instance.database;
      return await db.insert(
        'users',
        {'username': username, 'password': password},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print("Kullanıcı eklenirken bir hata oluştu: $e");
      rethrow;
    }
  }

  Future<bool> checkUser(String username, String password) async {
    try {
      Database db = await instance.database;
      List<Map<String, dynamic>> results = await db.query(
        'users',
        where: 'username = ? AND password = ?',
        whereArgs: [username, password],
      );
      return results.isNotEmpty;
    } catch (e) {
      print("Kullanıcı kontrol edilirken bir hata oluştu: $e");
      rethrow;
    }
  }

  Future<bool> checkUsernameExists(String username) async {
    try {
      Database db = await instance.database;
      List<Map<String, dynamic>> results = await db.query(
        'users',
        where: 'username = ?',
        whereArgs: [username],
      );
      return results.isNotEmpty;
    } catch (e) {
      print("Kullanıcı adı kontrol edilirken bir hata oluştu: $e");
      rethrow;
    }
  }

  Future<void> initDatabase() async {
    try {
      _database = await _initDatabase();
    } catch (e) {
      print("Veritabanı başlatılırken bir hata oluştu: $e");
      rethrow;
    }
  }

  Future<List<Task>> getAllTasksForUser(String username) async {
    try {
      Database db = await instance.database;
      List<Map<String, dynamic>> maps = await db.query(
        'tasks',
        where: 'username = ?',
        whereArgs: [username],
      );
      return List.generate(maps.length, (index) => Task.fromMap(maps[index]));
    } catch (e) {
      print("Kullanıcıya ait görevleri alırken bir hata oluştu: $e");
      rethrow;
    }
  }
}
