import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/reorderableList/reorderableListSimple.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'task.dart';

class TodoList extends StatefulWidget {
  @override
  createState() => TodoListState();
}

class TodoListState extends State<TodoList> {
  List<Task> todoList = [];
  List<Task> deleted = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _todoList = prefs.getString('todoList');

    if (todoList != null) {
      List<dynamic> taskList = jsonDecode(_todoList);
      setState(() =>
          todoList = taskList.map((item) => Task.fromJson(item)).toList());
    }
  }

  _setData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('todoList',
        json.encode(todoList.map((item) => (item.toJson())).toList()));
  }

  void _addTodoItem(Task task) {
    if (task.name.length > 0) {
      setState(() {
        todoList.add(task);
        todoList.sort((a, b) => a.idx.compareTo(b.idx));
      });
      _setData();
    }
  }

  void _removeTodoItem(int index) {
    var task = todoList[index];
    deleted.add(task);
    setState(() => todoList.removeAt(index));
    _setData();
  }

  void _toggleItemCheckbox(int index) {
    var checked = todoList[index].checked;
    setState(() => todoList[index].checked = !checked);
    _setData();
  }

  void _removeCheckedItems() {
    var removedItems = 0;
    todoList.toList().asMap().forEach((index, item) => {
          if (item.checked)
            {_removeTodoItem(index - removedItems), removedItems++}
        });
  }

  void _restoreDeletedTasks() {
    deleted.forEach((task) => _addTodoItem(task));
    setState(() => deleted = []);
  }

  // *********************
  //    *** DIALOGS ***
  // *********************
  void _promptClearDoneTasks() {
    var checkedTasks = todoList.where((t) => t.checked).length;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Clear all checked tasks?'),
            content: Text(
                'You have selected $checkedTasks ${checkedTasks > 1 ? 'tasks' : 'task'} to clear.'),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  'CANCEL',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              FlatButton(
                  child: Text(
                    'CLEAR',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  onPressed: () {
                    _removeCheckedItems();
                    Navigator.of(context).pop();
                  })
            ],
          );
        });
  }

  void _promptNoTasksToClear() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Nothing to clear'),
            content: Text('You did not check any task from your list.'),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        });
  }

  void _promptRestoreDeletedTasks() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Restore cleared tasks?'),
            content:
                Text('Your ${deleted.length} cleared tasks will be restored.'),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  'CANCEL',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              FlatButton(
                  child: Text(
                    'RESTORE',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  onPressed: () {
                    _restoreDeletedTasks();
                    Navigator.of(context).pop();
                  })
            ],
          );
        });
  }

  // *********************
  // *** DIALOGS - END ***
  // *********************

  Widget _buildTodoItem(BuildContext context, Task todoItem, int index) {
    return ListTile(
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              todoItem.checked
                  ? Icons.check_box
                  : Icons.check_box_outline_blank,
              size: 32,
              color: todoItem.checked ? Colors.green : Colors.grey,
            ),
          ],
        ),
        title: Padding(
            child: Text(todoItem.name),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0)),
        subtitle: Text(DateFormat('yyyy.MM.dd HH:mm')
            .format(DateTime.parse(todoItem.created))
            .toString()),
        onTap: () => _toggleItemCheckbox(index));
  }

  void _pushAddTodoScreen() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return Scaffold(
          appBar: AppBar(title: Text('Add task')),
          body: TextField(
            autofocus: true,
            autocorrect: true,
            onSubmitted: (val) {
              _addTodoItem(
                  Task(val, DateTime.now().toString(), false, todoList.length));
              Navigator.pop(context);
            },
            decoration: InputDecoration(
                hintText: 'Enter something to do...',
                contentPadding: const EdgeInsets.all(16.0)),
          ));
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreenAccent[50],
      appBar: AppBar(
        title: Padding(
          child: const Text(
            'what to do',
            style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w100,
                wordSpacing: 2,
                letterSpacing: 4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 5),
        ),
        backgroundColor: Colors.indigo,
        actions: <Widget>[
          // action button

          Padding(
            child: deleted.length > 0
                ? IconButton(
                    alignment: Alignment.centerLeft,
                    icon: Icon(
                      Icons.restore,
                      size: 36,
                    ),
                    onPressed: _promptRestoreDeletedTasks,
                  )
                : null,
            padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
          ),
          Padding(
            child: IconButton(
              alignment: Alignment.centerRight,
              icon: Icon(
                Icons.delete_forever,
                size: 36,
              ),
              onPressed: () {
                if (todoList.toList().where((t) => t.checked).length > 0) {
                  _promptClearDoneTasks();
                } else {
                  _promptNoTasksToClear();
                }
              },
            ),
            padding: const EdgeInsets.fromLTRB(0, 0, 18, 0),
          )
        ],
      ),
      body: ReorderableListSimple(
        onReorder: _onReorder,
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: todoList
            .map<Widget>(
                (task) => _buildTodoItem(context, task, todoList.indexOf(task)))
            .toList(),
        handleIcon: Icon(Icons.unfold_more, size: 36, color: Colors.indigo),
        onItemRemoved: _removeTodoItem,
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: _pushAddTodoScreen,
          tooltip: 'Add task',
          backgroundColor: Colors.indigoAccent,
          child: Icon(
            Icons.add,
          )),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      final Task item = todoList.removeAt(oldIndex);
      todoList.insert(newIndex, item);
      todoList[newIndex].idx = newIndex;
      todoList[oldIndex].idx = oldIndex;
    });
    _setData();
  }
}
