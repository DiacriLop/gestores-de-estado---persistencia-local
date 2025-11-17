import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_offline/features/tasks/presentation/providers/task_provider.dart';
import 'package:todo_offline/features/tasks/presentation/widgets/task_item.dart';
import 'package:todo_offline/features/tasks/data/models/task_model.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTasks();
    });
  }

  Future<void> _loadTasks() async {
    if (!mounted) return;
    final provider = Provider.of<TaskProvider>(context, listen: false);
    await provider.loadTasks();

    if (provider.error != null && mounted) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(provider.error!)));
      provider.clearError();
    }
  }

  Future<void> _showAddTaskDialog() async {
    final textController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Task'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: textController,
              decoration: const InputDecoration(
                labelText: 'Task title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a task title';
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            Consumer<TaskProvider>(
              builder: (context, taskProvider, _) {
                return ElevatedButton(
                  onPressed: taskProvider.isLoading
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            final title = textController.text.trim();
                            await taskProvider.addTask(title);

                            if (mounted) {
                              if (taskProvider.error != null) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(taskProvider.error!)),
                                );
                                taskProvider.clearError();
                              } else {
                                Navigator.of(context).pop();
                              }
                            }
                          }
                        },
                  child: taskProvider.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Add'),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _confirmDeleteTask(BuildContext context, int taskId) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Todo Offline'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadTasks,
                tooltip: 'Refresh tasks',
              ),
            ],
          ),
          body: _buildBody(context, taskProvider),
          floatingActionButton: FloatingActionButton(
            onPressed: _showAddTaskDialog,
            tooltip: 'Add new task',
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, TaskProvider taskProvider) {
    if (taskProvider.isLoading && taskProvider.tasks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (taskProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: ${taskProvider.error}',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadTasks, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (taskProvider.tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No tasks yet!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text('Tap the + button to add a new task.'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTasks,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: taskProvider.tasks.length,
        itemBuilder: (context, index) {
          final task = taskProvider.tasks[index];
          return Dismissible(
            key: Key('task-${task.id}'),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.endToStart) {
                return await _confirmDeleteTask(context, task.id!);
              }
              return false;
            },
            onDismissed: (direction) async {
              if (direction == DismissDirection.endToStart) {
                await taskProvider.deleteTask(task.id!);
                if (taskProvider.error != null && mounted) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(taskProvider.error!)));
                  taskProvider.clearError();
                }
              }
            },
            child: TaskItem(
              task: task,
              onToggle: () async {
                await taskProvider.toggleTaskCompletion(task);
                if (taskProvider.error != null && mounted) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(taskProvider.error!)));
                  taskProvider.clearError();
                }
              },
              onDelete: () async {
                final shouldDelete = await _confirmDeleteTask(
                  context,
                  task.id!,
                );
                if (shouldDelete == true && mounted) {
                  await taskProvider.deleteTask(task.id!);
                  if (taskProvider.error != null && mounted) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(taskProvider.error!)),
                    );
                    taskProvider.clearError();
                  }
                }
              },
            ),
          );
        },
      ),
    );
  }
}
