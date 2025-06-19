import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/task.dart';

class CalendarPage extends StatefulWidget {
  final List<Task> tasks;
  final Function(List<Task>) onTasksUpdated; // callback pour sauvegarder

  const CalendarPage({
    required this.tasks,
    required this.onTasksUpdated,
    super.key,
  });

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  void _addTask(String taskText) {
    if (_selectedDay == null) return;

    final newTask = Task(
      task: taskText,
      day: _selectedDay!.toIso8601String().substring(0, 10),
    );

    setState(() {
      widget.tasks.add(newTask);
    });

    widget.onTasksUpdated(widget.tasks);
  }

  Future<void> _showAddTaskDialog() async {
    final newTaskText = await showDialog<String>(
      context: context,
      builder: (context) => _AddTaskDialog(date: _selectedDay!),
    );
    if (newTaskText != null && newTaskText.isNotEmpty) {
      _addTask(newTaskText);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasksForSelectedDay = widget.tasks.where((task) {
      try {
        final taskDate = DateTime.parse(task.day);
        return taskDate.year == _selectedDay?.year &&
            taskDate.month == _selectedDay?.month &&
            taskDate.day == _selectedDay?.day;
      } catch (_) {
        return false;
      }
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Calendrier des tâches")),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) =>
                _selectedDay != null && isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarFormat: CalendarFormat.month,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: tasksForSelectedDay.length,
              itemBuilder: (context, index) {
                final task = tasksForSelectedDay[index];
                return ListTile(
                  title: Text(task.task),
                  trailing: Checkbox(
                    value: task.isChecked,
                    onChanged: (val) {
                      setState(() {
                        task.isChecked = val ?? false;
                      });
                      widget.onTasksUpdated(widget.tasks);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        tooltip: 'Ajouter une tâche',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AddTaskDialog extends StatefulWidget {
  final DateTime date;
  const _AddTaskDialog({required this.date, super.key});

  @override
  State<_AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<_AddTaskDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        "${widget.date.year}-${widget.date.month.toString().padLeft(2, '0')}-${widget.date.day.toString().padLeft(2, '0')}";

    return AlertDialog(
      title: Text('Ajouter une tâche pour le $formattedDate'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'Texte de la tâche'),
        onSubmitted: (_) {
          if (_controller.text.trim().isNotEmpty) {
            Navigator.pop(context, _controller.text.trim());
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_controller.text.trim().isNotEmpty) {
              Navigator.pop(context, _controller.text.trim());
            }
          },
          child: const Text('Ajouter'),
        ),
      ],
    );
  }
}
