// lib/features/calendar/widgets/new_task_fab.dart

import 'package:flutter/material.dart';

class NewTaskFab extends StatelessWidget {
  final VoidCallback onPressed;

  const NewTaskFab({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      label: const Text(
        "Nouvelle tâche",
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      icon: const Icon(Icons.add, color: Colors.white),
      backgroundColor: Colors.blue[700],
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}