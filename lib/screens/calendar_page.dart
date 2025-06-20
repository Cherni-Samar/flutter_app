import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/task.dart';

class CalendarPage extends StatefulWidget {
  final List<Task> tasks;
  final Function(List<Task>) onTasksUpdated;

  const CalendarPage({
    required this.tasks,
    required this.onTasksUpdated,
    Key? key,
  }) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<DateTime, List<Task>> _groupedTasks = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _groupTasks();
  }

  void _groupTasks() {
    _groupedTasks.clear();
    for (var task in widget.tasks) {
      try {
        final date = DateTime.parse(task.day);
        final day = DateTime(date.year, date.month, date.day);
        if (_groupedTasks[day] == null) _groupedTasks[day] = [];
        _groupedTasks[day]!.add(task);
      } catch (_) {}
    }
  }

  List<Task> _getTasksForDay(DateTime day) {
    return _groupedTasks[DateTime(day.year, day.month, day.day)] ?? [];
  }

  Future<void> _showAddTaskDialog() async {
    final TextEditingController _controller = TextEditingController();

    final newTaskText = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Ajouter une tâche pour le ${_formatDate(_selectedDay!)}"),
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
      ),
    );

    if (newTaskText != null && newTaskText.isNotEmpty) {
      final newTask = Task(
        task: newTaskText,
        day: _selectedDay!.toIso8601String().substring(0, 10),
      );

      setState(() {
        widget.tasks.add(newTask);
        _groupTasks();
      });
      widget.onTasksUpdated(widget.tasks);
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final tasksForDay = _getTasksForDay(_selectedDay!);

    return Scaffold(
      appBar: AppBar(title: const Text("Calendrier des tâches")),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarFormat: CalendarFormat.month,
            eventLoader: (day) => _getTasksForDay(day),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: tasksForDay.isEmpty
                ? Center(
                    child: Text(
                      'Aucune tâche pour le ${_formatDate(_selectedDay!)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: tasksForDay.length,
                    itemBuilder: (context, index) {
                      final task = tasksForDay[index];
                      return ListTile(
                        title: Text(
                          task.task,
                          style: TextStyle(
                            decoration: task.isChecked
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
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
