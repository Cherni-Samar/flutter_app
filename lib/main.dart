import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/task_controller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/task_storage_service.dart';
import 'screens/todo_list_screen.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/config/app_config.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();                    // Charger le fichier .env
  await AppConfig().load(); // Charge la config une fois

  final taskStorage = TaskStorageService();
  await taskStorage
      .autoCheckTasksIfNeeded(); // mise à jour automatique des tâches
  Get.put<TaskStorageService>(taskStorage);
  Get.put<TaskController>(TaskController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
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
