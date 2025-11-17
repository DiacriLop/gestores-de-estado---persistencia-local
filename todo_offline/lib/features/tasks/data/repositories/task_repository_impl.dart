import 'package:todo_offline/features/tasks/data/local/task_local_datasource.dart';
import 'package:todo_offline/features/tasks/data/models/task_model.dart';
import 'package:todo_offline/features/tasks/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDatasource _localDataSource;

  TaskRepositoryImpl({TaskLocalDatasource? localDataSource})
    : _localDataSource = localDataSource ?? TaskLocalDatasource();

  @override
  Future<List<TaskModel>> getTasks() async {
    try {
      return await _localDataSource.getTasks();
    } on Exception catch (e) {
      print('Error getting tasks: $e');
      rethrow;
    }
  }

  @override
  Future<void> insertTask(TaskModel task) async {
    try {
      await _localDataSource.insertTask(task);
    } on Exception catch (e) {
      print('Error inserting task: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    try {
      await _localDataSource.updateTask(task);
    } on Exception catch (e) {
      print('Error updating task: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteTask(int id) async {
    try {
      await _localDataSource.deleteTask(id);
    } on Exception catch (e) {
      print('Error deleting task: $e');
      rethrow;
    }
  }
}
