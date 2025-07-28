import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/task_controller.dart';
import '../models/task.dart';
import '../models/catch_up_task.dart';
import '../widgets/task_to_display.dart';
import '../services/api_service.dart';
import 'outlook_calendar_page.dart';

class TodoListScreen extends StatelessWidget {
  const TodoListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskController = Get.find<TaskController>();

    return Obx(() {
      // 1. Créer une copie de la liste pour ne pas modifier l'originale pendant la construction.
      final sortedTasks = RxList<Task>.from(taskController.tasks);
      
      // 2. Trier la copie.
      sortedTasks.sort(
        (a, b) => DateTime.parse(a.day).compareTo(DateTime.parse(b.day)),
      );

      // 3. Utiliser la copie triée (`sortedTasks`) pour le reste de la logique.
      Map<String, List<Task>> groupedTasks = {};
      for (var task in sortedTasks) {
        final dateKey = DateTime.parse(
          task.day,
        ).toLocal().toIso8601String().split('T')[0];
        groupedTasks.putIfAbsent(dateKey, () => []).add(task);
      }

      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E90FF),
          title: const Text(
            '🗂️ Tâches par date',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_today, color: Colors.white),
              tooltip: 'Voir calendrier',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OutlookCalendarPage(
                      tasks: sortedTasks, // Utiliser la liste triée ici aussi
                      onTasksUpdated: (updatedTasks) {
                        taskController.tasks.assignAll(updatedTasks);
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: groupedTasks.isEmpty
            ? const Center(
                child: Text(
                  "📝 Aucune tâche disponible",
                  style: TextStyle(color: Colors.grey),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(12),
                children: groupedTasks.entries.map((entry) {
                  final dateStr = entry.key;
                  final tasksForDate = entry.value;
                  // Utilisation d'un formatage plus sûr pour la date
                  final formattedDate = '${DateTime.parse(dateStr).toLocal()}'.split(' ')[0];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📅 $formattedDate',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF104E8B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...tasksForDate.map(
                        (task) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: TaskToDisplay(
                            task: task,
                            onToggle: () =>
                                taskController.toggleTaskCheck(task),
                            onDelete: () => taskController.deleteTask(task),
                            onEdit: () =>
                                _rescheduleTask(context, taskController, task),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                }).toList(),
              ),
      );
    });
  }

  Future<void> _rescheduleTask(
    BuildContext context,
    TaskController controller,
    Task oldTask,
  ) async {
    final TextEditingController textController = TextEditingController(
      text: oldTask.task,
    );
    DateTime? newDateTime = DateTime.parse(oldTask.day).toLocal();
    int newDuration = oldTask.durationMinutes;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Modifier l'horaire"),
          content: SingleChildScrollView( // Ajout pour éviter le débordement sur petits écrans
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: textController,
                  decoration: const InputDecoration(labelText: "Nom de la tâche"),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text("Date & heure : "),
                    TextButton(
                      onPressed: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: newDateTime!,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          final pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(newDateTime!),
                          );
                          if (pickedTime != null) {
                            setState(() {
                              newDateTime = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                pickedTime.hour,
                                pickedTime.minute,
                              );
                            });
                          }
                        }
                      },
                      child: Text(
                        newDateTime == null
                            ? "Choisir"
                            : "${newDateTime!.toLocal()}".split('.').first,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text("Durée (min) : "),
                    DropdownButton<int>(
                      value: newDuration,
                      items: [15, 30, 60, 90, 120]
                          .map(
                            (d) => DropdownMenuItem(value: d, child: Text('$d')),
                          )
                          .toList(),
                      onChanged: (val) => setState(() => newDuration = val ?? 60),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () {
                if (textController.text.trim().isEmpty || newDateTime == null) {
                  return;
                }
                Navigator.pop(context, true);
              },
              child: const Text("Valider"),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      oldTask.isModified = true;

      final newTask = Task(
        id: UniqueKey().toString(),
        task: textController.text.trim(),
        day: newDateTime!.toIso8601String(),
        durationMinutes: newDuration,
        isChecked: false,
        isModified: true,
      );

      controller.addTask(newTask);
      controller.updateTask(oldTask);

      // Créer la catchUpTask
      final catchUpTask = CatchUpTask(
        taskName: 'Rattrapage: ${textController.text.trim()}',
        catchUpDay: DateTime.now()
            .add(const Duration(days: 1))
            .toIso8601String(),
        durationMinutes: newDuration,
        isChecked: false,
        originalTaskId: oldTask.id!,
      );

      final success = await ApiService().sendCatchUpTaskToServer(catchUpTask);
      if (success) {
        if (kDebugMode) {
          print("CatchUpTask créée avec succès !");
        }
      } else {
        if (kDebugMode) {
          print("Erreur lors de la création de CatchUpTask.");
        }
      }
    }
  }
}