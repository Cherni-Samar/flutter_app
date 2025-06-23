import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/task.dart';
import 'package:flutter/services.dart' show rootBundle;

class TaskStorageService {
  Future<String> _localPath() async {
    final dir = await getApplicationDocumentsDirectory();
    if (kDebugMode) {
      print('📁 Chemin local : ${dir.path}/tasks.json');
    }
    return dir.path;
  }

  Future<File> _localFile() async {
    final path = await _localPath();
    return File('$path/tasks.json');
  }

  Future<List<Task>> loadTasks() async {
    try {
      final file = await _localFile();
      if (!await file.exists()) {
        // Copier depuis assets la première fois
        final data = await rootBundle.loadString('assets/tasks.json');
        await file.writeAsString(data);
      }
      final contents = await file.readAsString();
      final List<dynamic> jsonData = jsonDecode(contents);
      return jsonData.map((e) => Task.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final file = await _localFile();
    final jsonString = jsonEncode(tasks.map((e) => e.toJson()).toList());
    await file.writeAsString(jsonString);
  }

  Future<DateTime?> getLastAutoCheckDate() async {
    final path = await _localPath();
    final file = File('$path/last_update.txt');

    if (await file.exists()) {
      final content = await file.readAsString();
       //return DateTime.tryParse(content);
      return DateTime.now().subtract(
        Duration(days: 8),
      ); 
    }
    return null;
  }

  Future<void> setLastAutoCheckDate(DateTime date) async {
    final path = await _localPath();
    final file = File('$path/last_update.txt');
    await file.writeAsString(date.toIso8601String());
  }

  Future<void> autoCheckTasksIfNeeded() async {
    final lastDate = await getLastAutoCheckDate();
    final now = DateTime.now();

    if (lastDate == null || now.difference(lastDate).inDays >= 8) {
      final tasks = await loadTasks();
      print("✅ Mise à jour automatique : toutes les tâches seront cochées.");

      for (var task in tasks) {
        task.isChecked = false;
      }
      await saveTasks(tasks);
      await setLastAutoCheckDate(now);

      if (kDebugMode) {
        print("✅ Toutes les tâches ont été automatiquement cochées !");
      }
    } else {
      if (kDebugMode) {
        print("⏳ Moins de 7 jours depuis la dernière mise à jour auto.");
      }
    }
  }
  
}
