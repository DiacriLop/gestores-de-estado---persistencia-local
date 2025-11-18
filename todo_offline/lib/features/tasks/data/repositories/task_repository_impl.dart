import 'package:todo_offline/features/tasks/data/local/task_local_datasource.dart';
import 'package:todo_offline/features/tasks/data/models/task_model.dart';
import 'package:todo_offline/features/tasks/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDatasource _localDataSource;
  String? _error;

  TaskRepositoryImpl({TaskLocalDatasource? localDataSource})
    : _localDataSource = localDataSource ?? TaskLocalDatasource();

  @override
  Future<List<TaskModel>> getTasks() async {
    try {
      return await _localDataSource.getTasks();
    } on Exception catch (e) {
      _error = 'Error getting tasks: $e';
      print(_error);
      rethrow;
    }
  }

  @override
  Future<void> insertTask(TaskModel task) async {
    try {
      await _localDataSource.insertTask(task);
    } on Exception catch (e) {
      _error = 'Error inserting task: $e';
      print(_error);
      rethrow;
    }
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    try {
      await _localDataSource.updateTask(task);
    } on Exception catch (e) {
      _error = 'Error updating task: $e';
      print(_error);
      rethrow;
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      await _localDataSource.deleteTask(id);
    } on Exception catch (e) {
      _error = 'Error deleting task: $e';
      print(_error);
      rethrow;
    }
  }

  @override
  void clearError() {
    _error = null;
  }
}
