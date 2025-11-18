import 'package:sqflite/sqflite.dart';
import 'package:todo_offline/features/tasks/data/models/queue_operation_model.dart';

class QueueOperationDatasource {
  final Database db;

  QueueOperationDatasource({required this.db});

  static const String tableName = 'queue_operations';

  Future<void> enqueue(QueueOperationModel operation) async {
    await db.insert(
      tableName,
      operation.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<QueueOperationModel>> getPendingOperations() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'nextRetryAt IS NULL OR nextRetryAt <= ?',
      whereArgs: [now],
      orderBy: 'createdAt ASC',
    );

    return List.generate(maps.length, (i) {
      return QueueOperationModel.fromMap(maps[i]);
    });
  }

  Future<void> updateOperation(QueueOperationModel operation) async {
    await db.update(
      tableName,
      operation.toMap(),
      where: 'id = ?',
      whereArgs: [operation.id],
    );
  }

  Future<void> deleteOperation(String id) async {
    await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearCompletedOperations() async {
    await db.delete(
      tableName,
      where: 'nextRetryAt > ?',
      whereArgs: [DateTime.now().millisecondsSinceEpoch],
    );
  }
}
