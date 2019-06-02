import 'package:flutter/material.dart';

MaterialPageRoute editTodoScreen(
    String taskName, int taskIndex, Function setItem) {
  final taskController = TextEditingController(text: taskName);

  return MaterialPageRoute(builder: (context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Edit task'),
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
                    setItem(taskController.value.text.trim(), taskIndex);
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
                maxLength: 450,
                expands: true,
                autofocus: true,
                autocorrect: false,
                maxLengthEnforced: false,
                style: TextStyle(fontSize: 20),
                controller: taskController,
                onSubmitted: (val) {
                  setItem(val, taskIndex);
                  Navigator.pop(context);
                },
                decoration: InputDecoration.collapsed(
                  hintText: 'Enter something to do...',
                ))));
  });
}
