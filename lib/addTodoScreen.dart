import 'package:flutter/material.dart';
import 'package:my_app/task.dart';

MaterialPageRoute addTodoScreen(Function addItem, int listLength) {
  return MaterialPageRoute(builder: (context) {
    return Scaffold(
        appBar: AppBar(title: Text('Add task')),
        body: TextField(
          autofocus: true,
          autocorrect: true,
          onSubmitted: (val) {
            addItem(Task(val, DateTime.now().toString(), false, listLength));
            Navigator.pop(context);
          },
          decoration: InputDecoration(
              hintText: 'Enter something to do...',
              contentPadding: const EdgeInsets.all(16.0)),
        ));
  });
}
