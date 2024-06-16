
import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:collection'; 
import 'package:http/http.dart' as http;

import '../models/task.dart';


class TaskProvider with ChangeNotifier {
  final _baseUrl = 'https://to-do-listapp-dc078-default-rtdb.firebaseio.com';

  final List<Task> _tasks = [];

  UnmodifiableListView<Task> get tasks => UnmodifiableListView(_tasks);

  Future<void> loadTasks() async {
    try {
      print('Loading tasks...');
      final response = await http.get(Uri.parse('$_baseUrl/tasks.json'));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        print('Data received: $data'); // Adiciona um print para debug
        _tasks.clear();
        data.forEach((key, value) {
          final task = Task.fromJson(key, value);
          _tasks.add(task);
        });
        notifyListeners();
      } else {
        throw Exception('Failed to load tasks');
      }
    } catch (error) {
      print('Error loading tasks: $error');
      rethrow;
    }
  }

  Future<void> addTask(Task task) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/tasks.json'),
        body: jsonEncode(task.toJson()),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        _tasks.add(task.copyWith(id: body['name']));
        notifyListeners();
      } else {
        throw Exception('Failed to add task');
      }
    } catch (error) {
      print('Error adding task: $error');
      rethrow;
    }
  }

  Future<void> editTask(Task task) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/tasks/${task.id}.json'),
        body: jsonEncode(task.toJson()),
      );

      if (response.statusCode == 200) {
        final index = _tasks.indexWhere((elem) => elem.id == task.id);
        if (index != -1) {
          _tasks[index] = task;
          notifyListeners();
        }
      } else {
        throw Exception('Failed to update task');
      }
    } catch (error) {
      print('Error updating task: $error');
      rethrow;
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/tasks/$id.json'));

      if (response.statusCode == 200) {
        _tasks.removeWhere((task) => task.id == id);
        notifyListeners();
      } else {
        throw Exception('Failed to delete task');
      }
    } catch (error) {
      print('Error deleting task: $error');
      rethrow;
    }
  }
}