import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/task.dart';

class ApiService {
  final String baseUrl = 'http://192.168.100.15:3000/tasks';
  Future<bool> sendTaskToServer(Task task) async {
    final url = Uri.parse(baseUrl);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(task.toJson()),
    );

    if (kDebugMode) {
      print("🔁 Requête envoyée à $url");
    }
    if (kDebugMode) {
      print("📤 Données envoyées : ${task.toJson()}");
    }
    if (kDebugMode) {
      print("📥 Réponse : ${response.statusCode} | ${response.body}");
    }

    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<List<Task>> fetchTasks() async {
final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Task.fromJson(json)).toList();
    } else {
      throw Exception(
        'Erreur lors du chargement des tâches : ${response.statusCode}',
      );
    }
  }
}
