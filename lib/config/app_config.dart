// lib/config/app_config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static final AppConfig _instance = AppConfig._internal();

  factory AppConfig() => _instance;

  AppConfig._internal();

  late final String _apiHost;
  late final String _apiPort;
  late final String _protocol;
  late final String _tasksPath;
  late final String _catchUpPath;

  Future<void> load() async {
    _apiHost = dotenv.env['API_HOST'] ?? 'localhost';
    _apiPort = dotenv.env['API_PORT'] ?? '3000';
    _protocol = dotenv.env['API_PROTOCOL'] ?? 'http';
    _tasksPath = dotenv.env['TASKS_PATH'] ?? '/tasks';
    _catchUpPath = dotenv.env['CATCHUP_PATH'] ?? '/catchUpTasks';
  }
  

  String get baseUrl => '$_protocol://$_apiHost:$_apiPort';
  String get tasksUrl => '$baseUrl$_tasksPath';
  String get catchUpUrl => '$baseUrl$_catchUpPath';
}
