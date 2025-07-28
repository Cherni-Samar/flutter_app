import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/task.dart';
import '../models/catch_up_task.dart';

class ApiService {
  final AppConfig _config = AppConfig();

  final String baseUrl = AppConfig().tasksUrl;
  final String baseUrlCatchUp = AppConfig().catchUpUrl;

  Future<bool> sendTaskToServer(Task task) async {
    final url = Uri.parse(baseUrl);
    final Map<String, dynamic> jsonData = task.toJson();
    jsonData.remove('id');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(jsonData),
    );

    if (kDebugMode) {
      print("🔁 Requête envoyée à $url");
      print("📤 Données envoyées : $jsonData");
      print("📥 Réponse : ${response.statusCode} | ${response.body}");
    }

    return response.statusCode == HttpStatus.created;
  }

  Future<List<Task>> fetchTasks() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == HttpStatus.ok) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Task.fromJson(json)).toList();
    } else {
      throw Exception(
        'Erreur lors du chargement des tâches : ${response.statusCode}',
      );
    }
  }

  Future<bool> sendCatchUpTaskToServer(CatchUpTask catchUpTask) async {
    final url = Uri.parse(baseUrlCatchUp);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(catchUpTask.toJson()),
    );

    if (response.statusCode == HttpStatus.created) {
      return true;
    } else {
      if (kDebugMode) {
        print("Erreur CatchUpTask: ${response.statusCode}");
      }
      return false;
    }
  }
}
