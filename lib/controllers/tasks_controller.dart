import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';

class TasksController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _dbUrl = "https://todo-list-app-c366c-default-rtdb.firebaseio.com";

  var tasks = <TaskModel>[].obs;
  var isLoading = false.obs;
  var filterStatus = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    if (_auth.currentUser != null) fetchTasks();
  }

  Future<String?> _getToken() async {
    try {
      return await _auth.currentUser?.getIdToken();
    } catch (e) {
      return null;
    }
  }

  Future<void> fetchTasks() async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      isLoading.value = true;
      final token = await _getToken();
      final response = await http.get(
          Uri.parse('$_dbUrl/users/${user.uid}/tasks.json?auth=$token')
      );

      if (response.statusCode == 200 && response.body != 'null') {
        final Map<String, dynamic> decoded = json.decode(response.body);
        final List<TaskModel> loaded = [];
        decoded.forEach((key, value) {
          loaded.add(TaskModel.fromMap(Map<String, dynamic>.from(value)));
        });
        loaded.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        tasks.assignAll(loaded);
      } else {
        tasks.clear();
      }
    } finally {
      isLoading.value = false;
    }
  }
  Future<bool> addTask({
    required String title,
    required String description,
    required DateTime dueDate,
    required String priority,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      isLoading.value = true;
      final token = await user.getIdToken();
      final taskId = const Uuid().v4();

      final task = TaskModel(
        id: taskId,
        title: title,
        description: description,
        dueDate: dueDate,
        priority: priority,
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      final url = '$_dbUrl/users/${user.uid}/tasks/$taskId.json?auth=$token';

      final res = await http.put(
        Uri.parse(url),
        body: json.encode(task.toMap()),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        tasks.insert(0, task);
        tasks.refresh();
        return true;
      } else {
        Get.snackbar('Error', 'Server error. Check Firebase Rules.');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Network error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> updateTask({
    required String taskId,
    required String title,
    required String description,
    required DateTime dueDate,
    required String priority,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      isLoading.value = true;
      final token = await _getToken();
      await http.patch(
        Uri.parse('$_dbUrl/users/${user.uid}/tasks/$taskId.json?auth=$token'),
        body: json.encode({
          'title': title,
          'description': description,
          'dueDate': dueDate.millisecondsSinceEpoch,
          'priority': priority,
        }),
      );
      final index = tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        tasks[index] = tasks[index].copyWith(
          title: title,
          description: description,
          dueDate: dueDate,
          priority: priority,
        );
        tasks.refresh();
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleTaskCompletion(String taskId, bool currentStatus) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final token = await _getToken();
    await http.patch(
      Uri.parse('$_dbUrl/users/${user.uid}/tasks/$taskId.json?auth=$token'),
      body: json.encode({'isCompleted': !currentStatus}),
    );
    final index = tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      tasks[index] = tasks[index].copyWith(isCompleted: !currentStatus);
      tasks.refresh();
    }
  }

  Future<void> deleteTask(String taskId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final token = await _getToken();
    await http.delete(Uri.parse('$_dbUrl/users/${user.uid}/tasks/$taskId.json?auth=$token'));
    tasks.removeWhere((t) => t.id == taskId);
  }

  void setFilterStatus(String status) => filterStatus.value = status;
  List<TaskModel> get filteredTasks {
    if (filterStatus.value == 'active') return tasks.where((t) => !t.isCompleted).toList();
    if (filterStatus.value == 'completed') return tasks.where((t) => t.isCompleted).toList();
    return tasks;
  }
  int get activeTasksCount => tasks.where((t) => !t.isCompleted).length;
  int get completedTasksCount => tasks.where((t) => t.isCompleted).length;
}