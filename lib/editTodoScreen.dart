import 'package:flutter/material.dart';

MaterialPageRoute editTodoScreen(
    String taskName, int taskIndex, Function setItem) {
  final taskController = TextEditingController(text: taskName);

  return MaterialPageRoute(builder: (context) {
    return Scaffold(
        appBar: AppBar(title: Text('Edit task')),
        body: TextField(
          controller: taskController,
          autofocus: true,
          onSubmitted: (val) {
            setItem(val, taskIndex);
            Navigator.pop(context);
          },
          decoration: InputDecoration(
              hintText: 'Enter something to do...',
              contentPadding: const EdgeInsets.all(16.0)),
        ));
  });
}
