import 'package:flutter/foundation.dart';
import 'package:todo_offline/features/tasks/domain/repositories/task_repository.dart';
import 'package:todo_offline/features/tasks/data/models/task_model.dart';

class TaskProvider with ChangeNotifier {
  final TaskRepository _repository;
  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String? _error;

  TaskProvider({required TaskRepository repository}) : _repository = repository;

  List<TaskModel> get tasks => _tasks.where((task) => !task.deleted).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = await _repository.getTasks();
    } catch (e) {
      _error = 'Failed to load tasks';
      debugPrint('Error loading tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(String title) async {
    if (title.trim().isEmpty) {
      _error = 'Task title cannot be empty';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final task = TaskModel(
        title: title.trim(),
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        completed: false,
        deleted: false,
      );
      await _repository.insertTask(task);
      await loadTasks();
    } catch (e) {
      _error = 'Failed to add task: $e';
      debugPrint('Error adding task: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTask(TaskModel task) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedTask = task.copyWith(
        updatedAt: DateTime.now().toIso8601String(),
      );
      await _repository.updateTask(updatedTask);
      await loadTasks();
    } catch (e) {
      _error = 'Failed to update task: $e';
      debugPrint('Error updating task: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleTaskCompletion(TaskModel task) async {
    try {
      final updatedTask = task.copyWith(
        completed: !task.completed,
        updatedAt: DateTime.now().toIso8601String(),
      );
      await _repository.updateTask(updatedTask);
      await loadTasks();
    } catch (e) {
      _error = 'Failed to update task';
      debugPrint('Error toggling task: $e');
      rethrow;
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      await _repository.deleteTask(id);
      await loadTasks();
    } catch (e) {
      _error = 'Failed to delete task';
      debugPrint('Error deleting task: $e');
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
