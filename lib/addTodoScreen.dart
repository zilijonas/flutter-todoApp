import 'package:flutter/material.dart';
import 'package:my_app/task.dart';

MaterialPageRoute addTodoScreen(Function addItem, int listLength) {
  TextEditingController taskController = TextEditingController();
  return MaterialPageRoute(builder: (context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add task'),
        backgroundColor: Colors.indigo,
        actions: <Widget>[
          Padding(
            child: IconButton(
              alignment: Alignment.centerRight,
              icon: Icon(
                Icons.check,
                size: 36,
                semanticLabel: 'Save',
              ),
              onPressed: () {
                if (taskController.value.text.trim().length > 0) {
                  addItem(Task(taskController.value.text.trim(),
                      DateTime.now().toString(), false, listLength));
                  Navigator.pop(context);
                }
              },
            ),
            padding: const EdgeInsets.only(right: 16),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: TextField(
          minLines: null,
          maxLines: null,
          expands: true,
          autofocus: true,
          autocorrect: false,
          style: TextStyle(fontSize: 20),
          controller: taskController,
          onSubmitted: (val) {
            addItem(Task(val, DateTime.now().toString(), false, listLength));
            Navigator.pop(context);
          },
          decoration: InputDecoration.collapsed(
            hintText: 'Enter something to do...',
          ),
        ),
      ),
    );
  });
}
