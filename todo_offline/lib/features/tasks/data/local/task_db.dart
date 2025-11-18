import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class TaskDb {
  static const _databaseName = "todo_offline.db";
  static const _databaseVersion = 2; // Incremented for schema changes

  static final TaskDb instance = TaskDb._privateConstructor();
  static Database? _database;

  TaskDb._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _upgradeToVersion2(db);
    }
  }

  Future<void> _createTables(Database db) async {
    // Create tasks table with sync fields
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        completed INTEGER NOT NULL DEFAULT 0,
        deleted INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isSynced INTEGER NOT NULL DEFAULT 1,
        serverId TEXT
      )
    ''');

    // Create queue_operations table
    await db.execute('''
      CREATE TABLE queue_operations (
        id TEXT PRIMARY KEY,
        entity TEXT NOT NULL,
        entityId TEXT NOT NULL,
        operation TEXT NOT NULL,
        payload TEXT NOT NULL,
        createdAt INTEGER NOT NULL,
        attemptCount INTEGER NOT NULL DEFAULT 0,
        lastError TEXT,
        nextRetryAt INTEGER
      )
    ''');
  }

  Future<void> _upgradeToVersion2(Database db) async {
    // Rename old table
    await db.execute('ALTER TABLE tasks RENAME TO tasks_old');

    // Create new tables
    await _createTables(db);

    // Migrate data from old table
    await db.execute('''
      INSERT INTO tasks (id, title, completed, deleted, createdAt, updatedAt, isSynced)
      SELECT 
        id, 
        title, 
        completed, 
        deleted, 
        createdAt, 
        updatedAt,
        1 as isSynced
      FROM tasks_old
    ''');

    // Drop old table
    await db.execute('DROP TABLE tasks_old');
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}
