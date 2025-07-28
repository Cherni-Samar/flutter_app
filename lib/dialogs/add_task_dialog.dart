// lib/features/calendar/dialogs/add_task_dialog.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../models/task.dart';
import '../../../controllers/task_controller.dart';
import '../../../services/api_service.dart'; // Assurez-vous que le chemin est correct

Future<void> showAddTaskDialog(BuildContext context, DateTime startTime) async {
  final TaskController taskController = Get.find<TaskController>();
  final TextEditingController controller = TextEditingController();
  int selectedDuration = 60;
  final uuid = const Uuid();

  String formatHour(DateTime dt) =>
      "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Nouvelle tâche", style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Nom de la tâche',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text("Durée: ", style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButton<int>(
                    value: selectedDuration,
                    items: [30, 60, 90, 120]
                        .map((d) => DropdownMenuItem(value: d, child: Text('$d min')))
                        .toList(),
                    onChanged: (val) => setState(() => selectedDuration = val ?? 60),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Début à ${formatHour(startTime)}',
                  style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler", style: TextStyle(color: Colors.blue)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Ajouter", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ),
  );

  if (confirmed != true) return;

  // --- DÉBUT DE LA LOGIQUE DE VÉRIFICATION DES CONFLITS ---

  final newStart = startTime;
  final newEnd = newStart.add(Duration(minutes: selectedDuration));

  // On recherche une tâche existante qui entre en conflit avec le nouveau créneau.
  final conflict = taskController.tasks.any((existingTask) {
    // On ignore les tâches qui n'ont pas de date valide.
    final existingStart = DateTime.tryParse(existingTask.day);
    if (existingStart == null) return false;

    final existingEnd = existingStart.add(Duration(minutes: existingTask.durationMinutes));

    // La condition de conflit : le nouveau créneau chevauche un créneau existant.
    return newStart.isBefore(existingEnd) && newEnd.isAfter(existingStart);
  });

  // Si un conflit est détecté, on affiche un message et on arrête.
  if (conflict) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⛔ Conflit : une tâche existe déjà à ce créneau."),
          backgroundColor: Colors.red,
        ),
      );
    }
    return;
  }

  // --- FIN DE LA LOGIQUE DE VÉRIFICATION DES CONFLITS ---


  // Si aucun conflit n'est trouvé, on crée et on ajoute la tâche.
  final newTask = Task(
    id: uuid.v4(),
    task: controller.text.trim(),
    day: startTime.toIso8601String(),
    isChecked: false,
    durationMinutes: selectedDuration,
    isModified: false,
  );

  taskController.addTask(newTask);
  final success = await ApiService().sendTaskToServer(newTask);

  if (!context.mounted) return;
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(success ? "✅ Tâche envoyée avec succès !" : "⚠️ Enregistrement local seulement."),
      backgroundColor: success ? Colors.green : Colors.orange,
    ),
  );
}