import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import '../services/task_storage_service.dart';

class TaskController extends GetxController {
  var tasks = <Task>[].obs; // Liste réactive
  final TaskStorageService storageService = Get.find();
  final ApiService apiService = ApiService();

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }

  Future<void> loadTasks() async {
    try {
      final loadedTasks = await apiService.fetchTasks();

      // Assurer que chaque tâche a un id
      for (var task in loadedTasks) {
        if (task.id == null || task.id!.isEmpty) {
          task.id = UniqueKey().toString();
        }
      }

      tasks.assignAll(loadedTasks);
    } catch (e) {
      // En cas d'erreur, chargement local
      final localTasks = await storageService.loadTasks();
      tasks.assignAll(localTasks);
    }
  }

  void toggleTaskCheck(Task task) {
    task.isChecked = !task.isChecked;
    tasks.refresh(); // Notifier GetX pour update UI
    storageService.saveTasks(tasks);
  }

  void deleteTask(Task task) {
    tasks.remove(task);
    storageService.saveTasks(tasks);
  }

void addTask(Task task) {
  tasks.add(task);
  tasks.refresh(); // important pour mise à jour UI
  apiService.sendTaskToServer(task); // envoyer le task individuel
}



  void updateTask(Task updatedTask) {
    int index = tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      tasks[index] = updatedTask;
      storageService.saveTasks(tasks);
      tasks.refresh();
    }
  }
}
