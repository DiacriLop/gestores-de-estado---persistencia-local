import 'package:todo_offline/features/tasks/data/models/task_model.dart';

abstract class TaskRepository {
  Future<List<TaskModel>> getTasks();
  Future<void> insertTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(String id);

  // Optional: Add method to clear error if needed
  void clearError();
}
