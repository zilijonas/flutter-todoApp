import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(new TodoApp());

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(title: 'Todo List', home: new TodoList());
  }
}

class TodoList extends StatefulWidget {
  @override
  createState() => new TodoListState();
}

class Task {
  final String name;
  final String created;
  bool checked;

  Task.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        created = json['created'],
        checked = json['checked'];

  Map<String, dynamic> toJson() =>
      {'name': name, 'created': created, 'checked': checked};

  Task(this.name, this.created, this.checked);
}

class TodoListState extends State<TodoList> {
  List<Task> _todoItems = [];

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
      setState(() => _todoItems =
          taskList.map((item) => new Task.fromJson(item)).toList());
    }
  }

  _setData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('todoList',
        json.encode(_todoItems.map((item) => (item.toJson())).toList()));
  }

  void _addTodoItem(Task task) {
    if (task.name.length > 0) {
      setState(() {
        _todoItems.add(task);
        _todoItems.sort((a, b) => a.created.compareTo(b.created));
      });
      _setData();
    }
  }

  void _removeTodoItem(int index) {
    setState(() => _todoItems.removeAt(index));
    _setData();
  }

  void _toggleItemCheckbox(int index) {
    setState(() => _todoItems[index].checked = !_todoItems[index].checked);
    _setData();
  }

  void _removeCheckedItems() {
    var removedItems = 0;
    _todoItems.toList().asMap().forEach((index, item) => {
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
      itemCount: _todoItems.length,
      itemBuilder: (context, index) {
        if (index < _todoItems.length) {
          return _buildTodoItem(context, _todoItems[index], index);
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
          alignment: Alignment.centerLeft,
        ),
        secondaryBackground: Container(
          color: Colors.green,
          child: Icon(Icons.check_circle),
          alignment: Alignment.centerRight,
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
      appBar: new AppBar(title: new Text('Todo List')),
      body: Container(
          child: new Stack(children: <Widget>[
        new Positioned(
          child: _buildTodoList(),
        ),
        new Positioned(
          child: new Align(
              alignment: FractionalOffset.bottomCenter,
              child: new Container(
                  width: 150.0,
                  height: 50.0,
                  margin: const EdgeInsets.only(bottom: 20.0),
                  child: new RaisedButton(
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(10.0)),
                    onPressed: _promptClearDoneTasks,
                    child: const Text(
                      'Clear tasks',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    color: Color.fromRGBO(125, 20, 125, 1),
                    textColor: Colors.white,
                  ))),
        )
      ])),
      floatingActionButton: new FloatingActionButton(
          onPressed: _pushAddTodoScreen,
          tooltip: 'Add task',
          child: new Icon(Icons.add)),
    );
  }
}
