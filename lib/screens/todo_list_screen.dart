import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/outlook_calendar_page.dart';
import '../models/task.dart';
import '../services/task_storage_service.dart';
import '../widgets/task_to_display.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final TaskStorageService _storageService = TaskStorageService();
  List<Task> tasks = [];
  String? selectedDate; // Pour stocker la date sélectionnée dans la sidebar

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
    // Trier par date et heure
    tasks.sort(
      (a, b) => DateTime.parse(a.day).compareTo(DateTime.parse(b.day)),
    );

    // Extraire les jours uniques
    final uniqueDays = tasks.map((task) => DateTime.parse(task.day).toLocal().toIso8601String().split('T')[0]).toSet().toList();

    // Filtrer les tâches selon la date sélectionnée, ou toutes si aucune sélection
    final filteredTasks = selectedDate == null
        ? tasks
        : tasks.where((task) => DateTime.parse(task.day).toLocal().toIso8601String().split('T')[0] == selectedDate).toList();

    final Map<String, List<Task>> groupedTasks = {};
    for (var task in filteredTasks) {
      final dateKey = DateTime.parse(task.day).toLocal().toIso8601String().split('T')[0];
      groupedTasks.putIfAbsent(dateKey, () => []).add(task);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E90FF), // Bleu dodger
        title: const Text('🗂️ Tâches par date', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            tooltip: 'Voir calendrier',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OutlookCalendarPage(
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF1E90FF)), // Bleu dodger
              child: Text(
                'Choisir un jour',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ...uniqueDays.map((day) {
              final formattedDay = DateTime.parse(day).toLocal().toString().split(' ')[0];
              return ListTile(
                title: Text(formattedDay, style: const TextStyle(color: Color(0xFF104E8B))),
                onTap: () {
                  setState(() {
                    selectedDate = day;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
            ListTile(
              title: const Text('Tous les jours', style: TextStyle(color: Color(0xFF104E8B))),
              onTap: () {
                setState(() {
                  selectedDate = null;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Container(
        color: const Color(0xFFE6F0FA), // Bleu très clair
        padding: const EdgeInsets.all(12.0),
        child: groupedTasks.isEmpty
            ? const Center(child: Text("📝 Aucune tâche disponible", style: TextStyle(color: Colors.grey)))
            : ListView.builder(
                itemCount: groupedTasks.length,
                itemBuilder: (context, index) {
                  final dateStr = groupedTasks.keys.elementAt(index);
                  final tasksForDate = groupedTasks[dateStr]!;
                  final formattedDate = DateTime.parse(dateStr).toLocal().toString().split(' ')[0];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📅 $formattedDate',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF104E8B), // Bleu foncé slate
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: tasksForDate.length,
                        itemBuilder: (context, taskIndex) {
                          final task = tasksForDate[taskIndex];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: TaskToDisplay(
                              task: task,
                              onToggle: () => _toggleTaskCheck(task),
                              onDelete: () => _deleteTask(task),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                },
              ),
      ),
    );
  }
}