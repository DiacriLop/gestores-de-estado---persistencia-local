import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:todo_offline/features/tasks/data/models/task_model.dart';

class TaskItem extends StatefulWidget {
  final TaskModel task;
  final VoidCallback? onToggle;
  final VoidCallback? onDelete;
  final int index;

  const TaskItem({
    super.key,
    required this.task,
    required this.index,
    this.onToggle,
    this.onDelete,
  });

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem>
    with SingleTickerProviderStateMixin {
  static const _animationDuration = Duration(milliseconds: 300);
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isTapped = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    HapticFeedback.lightImpact();
    setState(() => _isTapped = true);
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails _) {
    setState(() => _isTapped = false);
    _animationController.reverse();
  }

  void _onTapCancel() {
    setState(() => _isTapped = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.onToggle,
        child: AnimatedContainer(
          duration: _animationDuration,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: _isTapped
                ? colorScheme.surfaceVariant.withOpacity(0.5)
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: widget.onToggle,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    // Custom Checkbox
                    Container(
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.task.completed
                              ? colorScheme.primary
                              : colorScheme.outlineVariant,
                          width: 2,
                        ),
                        color: widget.task.completed
                            ? colorScheme.primary
                            : Colors.transparent,
                      ),
                      child: widget.task.completed
                          ? Icon(
                              Icons.check,
                              size: 16,
                              color: colorScheme.onPrimary,
                            )
                          : null,
                    ),

                    // Task content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.task.title,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              decoration: widget.task.completed
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: widget.task.completed
                                  ? theme.hintColor
                                  : theme.textTheme.bodyLarge?.color,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(widget.task.updatedAt),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.hintColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Delete button
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: colorScheme.error.withOpacity(0.7),
                      ),
                      onPressed: widget.onDelete,
                      splashRadius: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Delete task',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${_twoDigits(date.day)}/${_twoDigits(date.month)}/${date.year} ${_twoDigits(date.hour)}:${_twoDigits(date.minute)}';
  }

  String _twoDigits(int n) => n >= 10 ? '$n' : '0$n';
}
