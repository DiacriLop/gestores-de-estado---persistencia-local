import 'package:flutter/foundation.dart';
import 'package:todo_offline/features/tasks/domain/repositories/task_repository.dart';
import 'package:todo_offline/features/tasks/data/models/task_model.dart';

// Enumeración para los tipos de filtro
enum TaskFilter { all, completed, pending }

class TaskProvider with ChangeNotifier {
  final TaskRepository _repository;
  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  TaskFilter _currentFilter = TaskFilter.all;

  TaskProvider({required TaskRepository repository}) : _repository = repository;

  // Getters
  List<TaskModel> get tasks => _tasks.where((task) => !task.deleted).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  TaskFilter get currentFilter => _currentFilter;

  // Obtener tareas filtradas
  List<TaskModel> get filteredTasks {
    var filtered = tasks; // tasks ya filtra las eliminadas

    // Aplicar filtro de estado
    switch (_currentFilter) {
      case TaskFilter.completed:
        filtered = filtered.where((task) => task.completed).toList();
        break;
      case TaskFilter.pending:
        filtered = filtered.where((task) => !task.completed).toList();
        break;
      case TaskFilter.all:
      default:
        break;
    }

    // Aplicar búsqueda
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered
          .where((task) => task.title.toLowerCase().contains(query))
          .toList();
    }

    // Ordenar por fecha de actualización (más recientes primero)
    filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return filtered;
  }

  // Método para actualizar el filtro
  void setFilter(TaskFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  // Método para actualizar la búsqueda
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

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
      final updatedTask = task.copyWith(updatedAt: DateTime.now());
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
        updatedAt: DateTime.now(),
      );
      await _repository.updateTask(updatedTask);
      await loadTasks();
    } catch (e) {
      _error = 'Failed to update task';
      debugPrint('Error toggling task: $e');
      rethrow;
    }
  }

  Future<void> deleteTask(String id) async {
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
