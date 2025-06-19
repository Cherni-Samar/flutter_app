import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_storage_service.dart';
import '../widgets/task_to_display.dart'; // TaskItem
import '../screens/calendar_page.dart'; // adapte le chemin si besoin

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final TaskStorageService _storageService = TaskStorageService();
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final loadedTasks = await _storageService.loadTasks();
    setState(() {
      tasks = loadedTasks;
    });
  }

  void _deleteTask(Task task) {
    setState(() {
      tasks.remove(task);
    });
    _storageService.saveTasks(tasks);
  }

  void _toggleTaskCheck(Task task) {
    setState(() {
      task.isChecked = !task.isChecked;
    });
    _storageService.saveTasks(tasks);
  }

  @override
  Widget build(BuildContext context) {
    // Trie les tâches par date croissante
    tasks.sort((a, b) => DateTime.parse(a.day).compareTo(DateTime.parse(b.day)));

    // Groupe les tâches par date (String "YYYY-MM-DD")
    final Map<String, List<Task>> groupedTasks = {};
    for (var task in tasks) {
      groupedTasks.putIfAbsent(task.day, () => []).add(task);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tâches par date'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            tooltip: 'Voir calendrier',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CalendarPage(
                    tasks: tasks,
                    onTasksUpdated: (updatedTasks) {
                      setState(() {
                        tasks = updatedTasks;
                      });
                      _storageService.saveTasks(tasks);
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: groupedTasks.isEmpty
            ? const Center(child: Text("Aucune tâche disponible"))
            : ListView(
                children: groupedTasks.entries.map((entry) {
                  final dateStr = entry.key;
                  final tasksForDate = entry.value;

                  // Formate la date en jj/mm/aaaa
                  final date = DateTime.tryParse(dateStr);
                  final formattedDate = date != null
                      ? "${date.day.toString().padLeft(2, '0')}/"
                        "${date.month.toString().padLeft(2, '0')}/"
                        "${date.year}"
                      : dateStr;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                      ...tasksForDate.map((task) => TaskItem(
                            task: task,
                            onToggle: () => _toggleTaskCheck(task),
                            onDelete: () => _deleteTask(task),
                          )),
                      const Divider(thickness: 1),
                    ],
                  );
                }).toList(),
              ),
      ),
    );
  }
}
