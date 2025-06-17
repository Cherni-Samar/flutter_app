import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color.fromARGB(255, 169, 200, 216),
      ),
      home: const TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final TextEditingController _controller = TextEditingController();
  String selectedDay = 'Lundi';
  final List<Map<String, dynamic>> tasks = []; // Liste de tâches avec jour et état

  final List<String> daysOfWeek = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];

  // Date de fin de semaine actuelle (dimanche 22 juin 2025, 23:59:59 CET)
  final DateTime endOfWeek = DateTime(2025, 6, 22, 23, 59, 59);

  void _addTask() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        tasks.add({'task': _controller.text, 'day': selectedDay, 'isChecked': false});
        _controller.clear();
        _resetTasksIfEndOfWeek(); // Vérifie après ajout
      });
    }
  }

  void _deleteTask(int index) {
    if (index >= 0 && index < tasks.length) {
      setState(() {
        tasks.removeAt(index);
        _resetTasksIfEndOfWeek(); // Vérifie après suppression
      });
    }
  }

  void _toggleTaskCheck(int index) {
    if (index >= 0 && index < tasks.length) {
      setState(() {
        tasks[index]['isChecked'] = !(tasks[index]['isChecked'] ?? false); // Gère le cas null
        _resetTasksIfEndOfWeek(); // Vérifie après changement
      });
    }
  }

  void _resetTasksIfEndOfWeek() {
    final now = DateTime.now().toUtc().add(const Duration(hours: 1)); // CET est UTC+1
    if (now.isAfter(endOfWeek)) {
      bool needsReset = false;
      for (var task in tasks) {
        if (task['isChecked'] == true) {
          needsReset = true;
          break;
        }
      }
      if (needsReset) {
        setState(() {
          for (var task in tasks) {
            task['isChecked'] = false;
          }
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _resetTasksIfEndOfWeek(); // Vérifie au démarrage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 77, 88, 242),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
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
                  items: daysOfWeek.map((String day) {
                    return DropdownMenuItem<String>(
                      value: day,
                      child: Text(day, style: const TextStyle(fontSize: 16)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedDay = newValue!;
                      _resetTasksIfEndOfWeek(); // Vérifie après changement de jour
                    });
                  },
                  style: const TextStyle(color: Colors.black),
                  dropdownColor: Colors.white,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down, color: Color.fromARGB(255, 71, 53, 231)),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 71, 53, 231),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Ajouter'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: daysOfWeek.length,
                itemBuilder: (context, dayIndex) {
                  final dayTasks = tasks.where((task) => task['day'] == daysOfWeek[dayIndex]).toList();
                  if (dayTasks.isEmpty) return const SizedBox.shrink();
                  return ExpansionTile(
                    title: Text(
                      daysOfWeek[dayIndex],
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 77, 88, 242)),
                    ),
                    leading: const Icon(Icons.calendar_today, color: Color.fromARGB(255, 77, 88, 242)),
                    children: dayTasks.asMap().entries.map((entry) {
                      final index = tasks.indexOf(entry.value);
                      final task = entry.value;
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: ListTile(
                          title: Text(
                            task['task'],
                            style: TextStyle(
                              fontSize: 16,
                              decoration: (task['isChecked'] ?? false) ? TextDecoration.lineThrough : TextDecoration.none,
                              color: (task['isChecked'] ?? false) ? Colors.grey : Colors.black,
                            ),
                          ),
                          leading: Checkbox(
                            value: task['isChecked'] ?? false,
                            onChanged: (bool? value) => _toggleTaskCheck(index),
                            activeColor: const Color.fromARGB(255, 77, 88, 242),
                          ),
                          trailing: GestureDetector(
                            onTap: () => _deleteTask(index),
                            child: const Icon(Icons.delete, color: Colors.red),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}