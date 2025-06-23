import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskToDisplay extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TaskToDisplay({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Extraire l'heure de début à partir de day (ISO 8601)
    final startTime = DateTime.parse(task.day).toLocal();
    final duration = Duration(minutes: task.durationMinutes);
    final endTime = startTime.add(duration);

    return Card(
      elevation: 3,
      color: _getTaskColor(task.task),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.task,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')} - '
              '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Checkbox(
                  value: task.isChecked,
                  onChanged: (_) => onToggle(),
                  activeColor: const Color(0xFF1E90FF), // Bleu dodger
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getTaskColor(String taskName) {
    final int hash = taskName.hashCode;
    if (hash % 4 == 0) return const Color(0xFF87CEEB); // Bleu ciel
    if (hash % 4 == 1) return const Color(0xFF4682B4); // Bleu acier
    if (hash % 4 == 2) return const Color(0xFFADD8E6); // Bleu clair
    return const Color(0xFFB0E0E6); // Bleu poudre
  }
}