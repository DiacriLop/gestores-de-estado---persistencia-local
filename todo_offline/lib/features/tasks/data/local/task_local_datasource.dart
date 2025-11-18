import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:todo_offline/features/tasks/data/models/task_model.dart';
import 'package:todo_offline/features/tasks/data/models/queue_operation_model.dart';
import 'task_db.dart';
import 'queue_operation_datasource.dart';

class TaskLocalDatasource {
  final TaskDb _db;
  Database? _database;
  bool _isInitialized = false;
  final _initCompleter = Completer<void>();
  late final QueueOperationDatasource _queueDatasource;

  TaskLocalDatasource({TaskDb? db}) : _db = db ?? TaskDb.instance {
    _init();
  }

  Future<void> _init() async {
    try {
      _database = await _db.database;
      _queueDatasource = QueueOperationDatasource(db: _database!);
      _isInitialized = true;
      _initCompleter.complete();
    } catch (e) {
      _initCompleter.completeError(e);
      rethrow;
    }
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await _initCompleter.future;
    }
  }

  void _convertToBool(Map<String, dynamic> map, String key) {
    if (!map.containsKey(key)) {
      map[key] = false;
      return;
    }

    final value = map[key];

    if (value == null) {
      map[key] = false;
    } else if (value is bool) {
      // Already a boolean, no conversion needed
      return;
    } else if (value is int) {
      map[key] = value == 1;
    } else if (value is String) {
      // Handle string "1", "0", "true", "false" (case insensitive)
      final strValue = value.trim().toLowerCase();
      map[key] = strValue == '1' || strValue == 'true';
    } else if (value is num) {
      // Handle other numeric types
      map[key] = value == 1;
    } else {
      // For any other type, convert to string and try to parse
      try {
        final strValue = value.toString().trim().toLowerCase();
        map[key] = strValue == '1' || strValue == 'true';
      } catch (e) {
        print('Error converting $key to boolean, defaulting to false');
        map[key] = false;
      }
    }
  }

  void _convertTaskMap(Map<String, dynamic> map) {
    print('\n[convertTaskMap] Converting map:');
    map.forEach((key, value) {
      print('  $key: $value (${value?.runtimeType})');
    });

    // Convert boolean fields
    _convertToBool(map, 'completed');
    _convertToBool(map, 'deleted');
    _convertToBool(map, 'isSynced');

    // Convert dates
    if (map['createdAt'] is String) {
      try {
        map['createdAt'] = DateTime.parse(map['createdAt']);
      } catch (e) {
        print('Error parsing createdAt: $e');
        map['createdAt'] = DateTime.now();
      }
    }

    if (map['updatedAt'] is String) {
      try {
        map['updatedAt'] = DateTime.parse(map['updatedAt']);
      } catch (e) {
        print('Error parsing updatedAt: $e');
        map['updatedAt'] = DateTime.now();
      }
    }

    print('[convertTaskMap] After conversion:');
    map.forEach((key, value) {
      print('  $key: $value (${value?.runtimeType})');
    });
  }

  Future<List<TaskModel>> getTasks({bool includeDeleted = false}) async {
    await _ensureInitialized();
    try {
      final db = _database!;
      final where = includeDeleted ? null : 'deleted = ?';
      final whereArgs = includeDeleted ? null : [0];

      print('\n[getTasks] Querying database...');
      final List<Map<String, dynamic>> maps = await db.query(
        'tasks',
        where: where,
        whereArgs: whereArgs,
        orderBy: 'updatedAt DESC',
      );

      print('[getTasks] Raw database results (${maps.length} tasks):');
      for (var i = 0; i < maps.length; i++) {
        print('\n[getTasks] Task #$i:');
        maps[i].forEach((key, value) {
          print('  $key: $value (${value?.runtimeType})');
        });
      }

      final results = <TaskModel>[];
      for (var i = 0; i < maps.length; i++) {
        try {
          print('\n[getTasks] Processing task #$i');
          final taskMap = Map<String, dynamic>.from(maps[i]);
          _convertTaskMap(taskMap);
          final task = TaskModel.fromMap(taskMap);
          results.add(task);
          print('[getTasks] Successfully created TaskModel: ${task.id}');
        } catch (e, stackTrace) {
          print('\n[getTasks] Error creating task: $e');
          print('Task data: ${maps[i]}');
          print('Stack trace: $stackTrace');
          rethrow;
        }
      }

      return results;
    } catch (e, stackTrace) {
      print('\n[getTasks] Error in getTasks: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // ... rest of the methods remain the same ...
  // [Previous implementation of other methods can be kept as is]

  Future<TaskModel> getTaskById(String id) async {
    await _ensureInitialized();
    try {
      final db = _database!;
      final maps = await db.query(
        'tasks',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isEmpty) {
        throw Exception('Task not found');
      }

      final map = Map<String, dynamic>.from(maps.first);
      _convertTaskMap(map);
      return TaskModel.fromMap(map);
    } catch (e, stackTrace) {
      print('[getTaskById] Error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<String> insertTask(TaskModel task) async {
    await _ensureInitialized();
    final db = _database!;
    final now = DateTime.now();
    final taskToInsert = task.copyWith(
      createdAt: now,
      updatedAt: now,
      isSynced: false,
    );

    try {
      await db.insert('tasks', taskToInsert.toMap());

      // Add to queue for sync
      await _queueDatasource.enqueue(
        QueueOperationModel(
          id: const Uuid().v4(),
          entity: 'task',
          entityId: taskToInsert.id,
          operation: OperationType.create,
          payload: taskToInsert.toMap(),
          createdAt: now,
        ),
      );

      return taskToInsert.id;
    } catch (e, stackTrace) {
      print('[insertTask] Error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> updateTask(TaskModel task) async {
    await _ensureInitialized();
    final db = _database!;
    final now = DateTime.now();
    final taskToUpdate = task.copyWith(updatedAt: now, isSynced: false);

    try {
      await db.update(
        'tasks',
        taskToUpdate.toMap(),
        where: 'id = ?',
        whereArgs: [task.id],
      );

      // Add to queue for sync
      await _queueDatasource.enqueue(
        QueueOperationModel(
          id: const Uuid().v4(),
          entity: 'task',
          entityId: taskToUpdate.id,
          operation: OperationType.update,
          payload: taskToUpdate.toMap(),
          createdAt: now,
        ),
      );
    } catch (e, stackTrace) {
      print('[updateTask] Error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> deleteTask(String id) async {
    await _ensureInitialized();
    final db = _database!;
    final now = DateTime.now();

    try {
      await db.update(
        'tasks',
        {'deleted': 1, 'updatedAt': now.toIso8601String(), 'isSynced': 0},
        where: 'id = ?',
        whereArgs: [id],
      );

      // Add to queue for sync
      await _queueDatasource.enqueue(
        QueueOperationModel(
          id: const Uuid().v4(),
          entity: 'task',
          entityId: id,
          operation: OperationType.delete,
          payload: {'id': id},
          createdAt: now,
        ),
      );
    } catch (e, stackTrace) {
      print('[deleteTask] Error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> markTaskAsSynced(String id, String serverId) async {
    await _ensureInitialized();
    final db = _database!;

    try {
      await db.update(
        'tasks',
        {
          'isSynced': 1,
          'serverId': serverId,
          'updatedAt': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e, stackTrace) {
      print('[markTaskAsSynced] Error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<List<TaskModel>> getUnsyncedTasks() async {
    await _ensureInitialized();
    final db = _database!;

    try {
      print('[getUnsyncedTasks] Fetching unsynced tasks...');
      final maps = await db.query(
        'tasks',
        where: 'isSynced = ?',
        whereArgs: [0],
      );

      print('[getUnsyncedTasks] Found ${maps.length} unsynced tasks');
      final results = <TaskModel>[];

      for (var map in maps) {
        try {
          final taskMap = Map<String, dynamic>.from(map);
          _convertTaskMap(taskMap);
          final task = TaskModel.fromMap(taskMap);
          results.add(task);
        } catch (e, stackTrace) {
          print('[getUnsyncedTasks] Error creating task: $e');
          print('Task data: $map');
          print('Stack trace: $stackTrace');
          rethrow;
        }
      }

      return results;
    } catch (e, stackTrace) {
      print('[getUnsyncedTasks] Error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
