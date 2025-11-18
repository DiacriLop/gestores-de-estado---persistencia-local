import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_offline/features/tasks/data/models/task_model.dart';
import 'package:todo_offline/features/tasks/presentation/providers/task_provider.dart';
import 'package:todo_offline/features/tasks/presentation/widgets/task_item.dart';
import 'package:todo_offline/core/theme/app_colors.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  @override
  void initState() {
    super.initState();
    // Ya NO hace falta recargar manualmente: el Provider carga en main()
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkErrors();
    });
  }

  /// Solo muestra errores si el provider los trae después de cargar
  void _checkErrors() {
    final provider = context.read<TaskProvider>();

    if (provider.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(provider.error!)));
      provider.clearError();
    }
  }

  Future<void> _loadTasks() async {
    final provider = context.read<TaskProvider>();
    await provider.loadTasks();

    if (!mounted) return;
    if (provider.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(provider.error!)));
      provider.clearError();
    }
  }

  Future<void> _showAddTaskDialog() async {
    final textController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final theme = Theme.of(context);

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Add New Task', style: theme.textTheme.titleLarge),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: textController,
                    maxLines: 3,
                    minLines: 1,
                    decoration: const InputDecoration(
                      hintText: 'What needs to be done?',
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? "Enter a task" : null,
                  ),
                  const SizedBox(height: 16),
                  Consumer<TaskProvider>(
                    builder: (_, provider, __) {
                      return FilledButton(
                        onPressed: provider.isLoading
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                await provider.addTask(
                                  textController.text.trim(),
                                );

                                if (!mounted) return;

                                if (provider.error != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(provider.error!)),
                                  );
                                  provider.clearError();
                                } else {
                                  Navigator.pop(context);
                                }
                              },
                        child: provider.isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text("Add Task"),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool?> _confirmDeleteTask(TaskModel task) async {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("CANCEL"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("DELETE"),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(TaskProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip(
            context: context,
            label: 'All',
            isSelected: provider.currentFilter == TaskFilter.all,
            onSelected: (_) => provider.setFilter(TaskFilter.all),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context: context,
            label: 'Completed',
            isSelected: provider.currentFilter == TaskFilter.completed,
            onSelected: (_) => provider.setFilter(TaskFilter.completed),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context: context,
            label: 'Pending',
            isSelected: provider.currentFilter == TaskFilter.pending,
            onSelected: (_) => provider.setFilter(TaskFilter.pending),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required Function(bool) onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: isSelected
            ? Theme.of(context).colorScheme.onPrimaryContainer
            : Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outlineVariant,
          width: isSelected ? 1.0 : 0.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      showCheckmark: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (_, provider, __) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'My Tasks',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
            centerTitle: true,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: _loadTasks,
                tooltip: 'Refresh tasks',
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _showAddTaskDialog,
            label: const Text(
              'Add Task',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            icon: const Icon(Icons.add_rounded, size: 24),
            elevation: 3,
            highlightElevation: 6,
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            materialTapTargetSize: MaterialTapTargetSize.padded,
          ),
          body: _buildBody(provider),
        );
      },
    );
  }

  Widget _buildBody(TaskProvider provider) {
    if (provider.isLoading && provider.tasks.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                provider.error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.tonal(
              onPressed: _loadTasks,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    final tasksToShow = provider.filteredTasks;

    if (tasksToShow.isEmpty) {
      return Column(
        children: [
          _buildFilterChips(provider),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      size: 80,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.2),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      provider.currentFilter == TaskFilter.completed
                          ? 'No completed tasks'
                          : provider.currentFilter == TaskFilter.pending
                          ? 'No pending tasks'
                          : 'No tasks yet!',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.currentFilter == TaskFilter.completed
                          ? 'Complete some tasks to see them here.'
                          : provider.currentFilter == TaskFilter.pending
                          ? 'All caught up! No pending tasks.'
                          : 'Tap the + button to add your first task.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildFilterChips(provider),
        Expanded(
          child: RefreshIndicator.adaptive(
            onRefresh: _loadTasks,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              itemCount: tasksToShow.length,
              itemBuilder: (_, index) {
                final task = tasksToShow[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Dismissible(
                    key: Key('task-${task.id}'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      child: const Icon(
                        Icons.delete_forever_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    confirmDismiss: (_) => _confirmDeleteTask(task),
                    onDismissed: (_) async {
                      await provider.deleteTask(task.id);
                      if (mounted && provider.error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(provider.error!)),
                        );
                        provider.clearError();
                      }
                    },
                    child: TaskItem(
                      task: task,
                      index: index,
                      onToggle: () => provider.toggleTaskCompletion(task),
                      onDelete: () async {
                        final confirm = await _confirmDeleteTask(task);
                        if (confirm == true) {
                          await provider.deleteTask(task.id);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
