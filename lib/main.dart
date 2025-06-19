import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/task_storage_service.dart';
import 'screens/todo_list_screen.dart';

Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
  final taskStorage = TaskStorageService();
  await taskStorage.autoCheckTasksIfNeeded(); // ← Appel ici
  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plan Of Week',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color.fromARGB(255, 169, 200, 216),
      ),
      home: const TodoListScreen(),
      
      
    );
  }
}
