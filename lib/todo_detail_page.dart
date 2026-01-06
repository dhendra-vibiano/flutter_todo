import 'package:flutter/material.dart';

class TodoDetailPage extends StatelessWidget {
  final String todo;

  const TodoDetailPage({
    super.key,
    required this.todo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: const Text(
          'Detail Tugas',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              todo,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
