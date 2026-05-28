import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studyflow/core/network/api_constants.dart';
import 'package:studyflow/features/task/data/models/task_model.dart';

/// Data source for managing task operations with .NET API.
class TaskRemoteDatasource {
  final FirebaseAuth auth;
  final String taskEndpoint = '${ApiConstants.baseUrl}/tasks';

  TaskRemoteDatasource({required this.auth});

  /// Gets a list of the user's tasks from API.
  Future<List<TaskModel>> getTasks() async {
    final headers = await ApiConstants.getAuthHeaders(auth);
    final response = await http.get(Uri.parse(taskEndpoint), headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => TaskModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tasks from API');
    }
  }

  /// Adds a new task via API.
  Future<void> addTask(TaskModel task) async {
    final headers = await ApiConstants.getAuthHeaders(auth);
    final response = await http.post(
      Uri.parse(taskEndpoint),
      headers: headers,
      body: json.encode(task.toJson()),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to create task');
    }
  }

  /// Updates an existing task via API.
  Future<void> updateTask(TaskModel task) async {
    final headers = await ApiConstants.getAuthHeaders(auth);
    final response = await http.put(
      Uri.parse('$taskEndpoint/${task.id}'),
      headers: headers,
      body: json.encode(task.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update task');
    }
  }

  /// Deletes a task via API.
  Future<void> deleteTask(String id) async {
    final headers = await ApiConstants.getAuthHeaders(auth);
    final response = await http.delete(
      Uri.parse('$taskEndpoint/$id'),
      headers: headers,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete task');
    }
  }
}
