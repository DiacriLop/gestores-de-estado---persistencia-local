import 'package:flutter/material.dart';
import 'package:todo_offline/features/tasks/data/models/task_model.dart';

class TaskItem extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onToggle;
  final VoidCallback? onDelete;

  const TaskItem({super.key, required this.task, this.onToggle, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      elevation: 1.0,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        leading: Checkbox(
          value: task.completed,
          onChanged: (_) => onToggle?.call(),
          activeColor: theme.primaryColor,
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontSize: 16.0,
            decoration: task.completed ? TextDecoration.lineThrough : null,
            color: task.completed
                ? theme.hintColor
                : theme.textTheme.titleMedium?.color,
          ),
        ),
        subtitle: task.updatedAt.isNotEmpty
            ? Text(
                'Updated: ${_formatDate(task.updatedAt)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              )
            : null,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onDelete,
          tooltip: 'Delete task',
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${_twoDigits(date.day)}/${_twoDigits(date.month)}/${date.year} ${_twoDigits(date.hour)}:${_twoDigits(date.minute)}';
    } catch (e) {
      return dateString;
    }
  }

  String _twoDigits(int n) => n >= 10 ? '$n' : '0$n';
}
