import 'package:flutter/material.dart';
import '../models/todo_model.dart';
import '../helpers/database_helper.dart';
import '../helpers/notification_helper.dart';

class TodoProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final NotificationHelper _notificationHelper = NotificationHelper();

  List<Todo> _todos = [];
  String _filter = 'All'; // 'All', 'Active', 'Done'

  List<Todo> get todos {
    if (_filter == 'Active') {
      return _todos.where((todo) => !todo.isCompleted).toList();
    } else if (_filter == 'Done') {
      return _todos.where((todo) => todo.isCompleted).toList();
    }
    return _todos;
  }

  TodoProvider() {
    _notificationHelper.init(); // Initialize notifications
    loadTodos();
  }

  Future<void> loadTodos() async {
    try {
      _todos = await _dbHelper.getTodos();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading todos: $e');
    }
  }

  Future<void> addTodo(Todo todo) async {
    try {
      int id = await _dbHelper.insertTodo(todo);
      // If there is a due date and reminder is active, schedule notification
      if (todo.dueDate != null && todo.isReminderActive) {
        await _notificationHelper.scheduleNotification(
          id,
          'Reminder: ${todo.title}',
          todo.description.isNotEmpty ? todo.description : 'It\'s time for your task!',
          todo.dueDate!,
        );
      }
      await loadTodos();
    } catch (e) {
      debugPrint('Error adding todo: $e');
    }
  }

  Future<void> updateTodo(Todo todo) async {
    try {
      await _dbHelper.updateTodo(todo);
      
      // Update notification
      if (todo.dueDate != null && todo.isReminderActive) {
        // Cancel old one just in case and schedule new
         await _notificationHelper.cancelNotification(todo.id!);
         await _notificationHelper.scheduleNotification(
          todo.id!,
          'Reminder: ${todo.title}',
          todo.description.isNotEmpty ? todo.description : 'It\'s time for your task!',
          todo.dueDate!,
        );
      } else {
        // If reminder turned off, cancel it
        await _notificationHelper.cancelNotification(todo.id!);
      }

      await loadTodos();
    } catch (e) {
      debugPrint('Error updating todo: $e');
    }
  }

  Future<void> deleteTodo(int id) async {
    await _dbHelper.deleteTodo(id);
    await _notificationHelper.cancelNotification(id);
    await loadTodos();
  }

  Future<void> toggleTodo(Todo todo) async {
    final newTodo = todo.copyWith(isCompleted: !todo.isCompleted);
    await updateTodo(newTodo);
  }

  void setFilter(String filter) {
    _filter = filter;
    notifyListeners();
  }
}
