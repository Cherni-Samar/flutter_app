import 'package:flutter/material.dart';

class TaskInput extends StatelessWidget {
  final TextEditingController controller;
  final String selectedDay;
  final List<String> daysOfWeek;
  final ValueChanged<String?> onDayChanged;
  final VoidCallback onAddTask;

  const TaskInput({
    Key? key,
    required this.controller,
    required this.selectedDay,
    required this.daysOfWeek,
    required this.onDayChanged,
    required this.onAddTask,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Entrez une tâche',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 10),
        DropdownButton<String>(
          value: selectedDay,
          items: daysOfWeek.map((day) => DropdownMenuItem<String>(
            value: day,
            child: Text(day, style: const TextStyle(fontSize: 16)),
          )).toList(),
          onChanged: onDayChanged,
          dropdownColor: Colors.white,
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: onAddTask,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 71, 53, 231),
            foregroundColor: Colors.white,
          ),
          child: const Text('Ajouter'),
        ),
      ],
    );
  }
}
