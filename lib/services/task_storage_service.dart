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
}
