import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskToDisplay extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;

  const TaskToDisplay({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    this.onEdit,
  });

  Color _getTaskColor(Task task) {
    if (task.isModified) {
      return Colors.red.withOpacity(0.7); // tâche déplacée ou remplacée
    }

    final int hash = task.task.hashCode;
    if (hash % 4 == 0) return const Color(0xFF87CEEB);
    if (hash % 4 == 1) return const Color(0xFF4682B4);
    if (hash % 4 == 2) return const Color(0xFFADD8E6);
    return const Color(0xFFB0E0E6);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _getTaskColor(task),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onToggle,
              child: Text(
                task.task,
                style: TextStyle(
                  decoration: task.isChecked ? TextDecoration.lineThrough : null,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              task.isChecked ? Icons.check_box : Icons.check_box_outline_blank,
              color: Colors.white,
            ),
            onPressed: onToggle,
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.orangeAccent),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
