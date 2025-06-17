import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_storage_service.dart';
import '../widgets/task_input.dart';
import '../widgets/task_to_display.dart';
import '../utils/constants.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({Key? key}) : super(key: key);

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final TaskStorageService _storageService = TaskStorageService();
  final TextEditingController _controller = TextEditingController();
  String selectedDay = daysOfWeek[0];
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

  void _addTask() {
    if (_controller.text.isEmpty) return;
    final newTask = Task(task: _controller.text, day: selectedDay);
    setState(() {
      tasks.add(newTask);
      _controller.clear();
    });
    _storageService.saveTasks(tasks);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TaskInput(
              controller: _controller,
              selectedDay: selectedDay,
              daysOfWeek: daysOfWeek,
              onDayChanged: (day) {
                if (day != null) {
                  setState(() {
                    selectedDay = day;
                  });
                }
              },
              onAddTask: _addTask,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: daysOfWeek.map((day) {
                  final dayTasks = tasks.where((t) => t.day == day).toList();
                  if (dayTasks.isEmpty) return const SizedBox.shrink();
                  return ExpansionTile(
                    title: Text(day),
                    children: dayTasks.map((task) {
                      return TaskItem(
                        task: task,
                        onToggle: () => _toggleTaskCheck(task),
                        onDelete: () => _deleteTask(task),
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
