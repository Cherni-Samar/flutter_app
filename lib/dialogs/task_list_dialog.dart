// lib/features/calendar/dialogs/task_list_dialog.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/task.dart';
import '../../../controllers/task_controller.dart';

Future<void> showTaskListDialog(BuildContext context, DateTime date) async {
  final TaskController taskController = Get.find<TaskController>();

  String formatDate(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";

  List<Task> tasksForSelectedDate() {
    final selectedDayString = date.toIso8601String().substring(0, 10);
    return taskController.tasks.where((t) => t.day.startsWith(selectedDayString)).toList()
      ..sort((a, b) => a.day.compareTo(b.day));
  }

  final tasks = tasksForSelectedDate();

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text('Tâches pour ${formatDate(date)}', style: const TextStyle(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: double.maxFinite,
        child: tasks.isEmpty
            ? const Center(
                child: Text('Aucune tâche pour ce jour.', style: TextStyle(fontStyle: FontStyle.italic)),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: Text(task.task, style: const TextStyle(fontSize: 16)),
                    subtitle: task.isModified ? const Text("🟢 Modifiée") : null,
                    trailing: Checkbox(
                      value: task.isChecked,
                      activeColor: Colors.blue[700],
                      onChanged: (val) {
                        taskController.toggleTaskCheck(task);
                        Navigator.pop(context); // Ferme le dialogue après le changement
                      },
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Fermer", style: TextStyle(color: Colors.blue)),
        ),
      ],
    ),
  );
}