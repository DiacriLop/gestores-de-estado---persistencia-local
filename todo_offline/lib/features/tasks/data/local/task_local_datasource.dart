import 'package:todo_offline/features/tasks/data/models/task_model.dart';
import 'task_db.dart';

class TaskLocalDatasource {
  final TaskDb _db;

  TaskLocalDatasource({TaskDb? db}) : _db = db ?? TaskDb.instance;

  Future<List<TaskModel>> getTasks() async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'deleted = ?',
      whereArgs: [0],
      orderBy: 'updatedAt DESC',
    );
    return List.generate(maps.length, (i) => TaskModel.fromMap(maps[i]));
  }

  Future<int> insertTask(TaskModel task) async {
    final db = await _db.database;
    final now = DateTime.now().toIso8601String();
    final taskToInsert = task.copyWith(createdAt: now, updatedAt: now);
    return await db.insert('tasks', taskToInsert.toMap());
  }

  Future<int> updateTask(TaskModel task) async {
    final db = await _db.database;
    final now = DateTime.now().toIso8601String();
    final taskToUpdate = task.copyWith(updatedAt: now);
    return await db.update(
      'tasks',
      taskToUpdate.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await _db.database;
    final now = DateTime.now().toIso8601String();
    return await db.update(
      'tasks',
      {'deleted': 1, 'updatedAt': now},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearDatabase() async {
    final db = await _db.database;
    await db.delete('tasks');
  }
}
