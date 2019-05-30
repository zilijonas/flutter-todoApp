import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'task.dart';

class TodoList extends StatefulWidget {
  @override
  createState() => new TodoListState();
}

class TodoListState extends State<TodoList> {
  List<Task> _todoList = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String todoList = prefs.getString('todoList');

    if (todoList != null) {
      List<dynamic> taskList = jsonDecode(todoList);
      setState(() =>
          _todoList = taskList.map((item) => new Task.fromJson(item)).toList());
    }
  }

  _setData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('todoList',
        json.encode(_todoList.map((item) => (item.toJson())).toList()));
  }

  void _addTodoItem(Task task) {
    if (task.name.length > 0) {
      setState(() {
        _todoList.add(task);
        _todoList.sort((a, b) => a.created.compareTo(b.created));
      });
      _setData();
    }
  }

  void _removeTodoItem(int index) {
    setState(() => _todoList.removeAt(index));
    _setData();
  }

  void _toggleItemCheckbox(int index) {
    setState(() => _todoList[index].checked = !_todoList[index].checked);
    _setData();
  }

  void _removeCheckedItems() {
    var removedItems = 0;
    _todoList.toList().asMap().forEach((index, item) => {
          if (item.checked)
            {_removeTodoItem(index - removedItems), removedItems++}
        });
  }

  void _promptClearDoneTasks() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text('Clear all checked tasks?'),
            actions: <Widget>[
              new FlatButton(
                child: new Text('CANCEL'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              new FlatButton(
                  child: new Text('CLEAR'),
                  onPressed: () {
                    _removeCheckedItems();
                    Navigator.of(context).pop();
                  })
            ],
          );
        });
  }

  Widget _buildTodoList() {
    return new ListView.separated(
      separatorBuilder: (context, index) =>
          Divider(color: Colors.black, height: 1),
      itemCount: _todoList.length,
      itemBuilder: (context, index) {
        if (index < _todoList.length) {
          return _buildTodoItem(context, _todoList[index], index);
        }
      },
    );
  }

  Widget _buildTodoItem(BuildContext context, Task todoItem, int index) {
    return new Dismissible(
        key: Key(todoItem.created),
        onDismissed: (DismissDirection dir) {
          _removeTodoItem(index);

          Scaffold.of(context).showSnackBar(SnackBar(
              content: Text(dir == DismissDirection.startToEnd
                  ? '"${todoItem.name}" deleted.'
                  : '"${todoItem.name}" marked as done and removed.'),
              action: SnackBarAction(
                label: 'UNDO',
                onPressed: () {
                  setState(() => _addTodoItem(todoItem));
                },
              )));
        },
        background: Container(
          color: Colors.red,
          child: Icon(Icons.delete),
          alignment: Alignment.center,
        ),
        secondaryBackground: Container(
          color: Colors.green,
          child: Icon(Icons.check_circle),
          alignment: Alignment.center,
        ),
        child: ListTile(
            leading: new Checkbox(
              value: todoItem.checked,
              onChanged: (bool value) {
                _toggleItemCheckbox(index);
              },
            ),
            title: new Text(todoItem.name),
            subtitle: new Text(new DateFormat('yyyy.MM.dd HH:mm')
                .format(DateTime.parse(todoItem.created))
                .toString()),
            onTap: () => _toggleItemCheckbox(index)));
  }

  void _pushAddTodoScreen() {
    Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
      return new Scaffold(
          appBar: new AppBar(title: new Text('Add new task')),
          body: new TextField(
            autofocus: true,
            autocorrect: true,
            onSubmitted: (val) {
              _addTodoItem(new Task(val, new DateTime.now().toString(), false));
              Navigator.pop(context);
            },
            decoration: new InputDecoration(
                hintText: 'Enter something to do...',
                contentPadding: const EdgeInsets.all(16.0)),
          ));
    }));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: const Text('what to do'),
        actions: <Widget>[
          // action button

          Padding(
            child: IconButton(
              alignment: Alignment.centerLeft,
              icon: Icon(
                Icons.delete_forever,
                size: 36,
              ),
              onPressed: () {
                if (_todoList.toList().where((t) => t.checked).length > 0)
                  _promptClearDoneTasks();
              },
            ),
            padding: const EdgeInsets.fromLTRB(0, 0, 30, 0),
          )
        ],
      ),

      //new AppBar(title: new Text('Todo List')),
      body: Container(
          child: new Stack(children: <Widget>[
        new Positioned(
          child: _buildTodoList(),
        ),
      ])),
      floatingActionButton: new FloatingActionButton(
          onPressed: _pushAddTodoScreen,
          tooltip: 'Add task',
          child: new Icon(Icons.add)),
    );
  }
}
