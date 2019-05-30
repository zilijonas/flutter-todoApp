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
          todoList = taskList.map((item) => new Task.fromJson(item)).toList());
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
        todoList.sort((a, b) => a.created.compareTo(b.created));
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

  void _restoreDeletedTasks() {
    deleted.forEach((task) => _addTodoItem(task));
    setState(() => deleted = []);
  }

  Widget _buildTodoList() {
    return new ListView.separated(
      separatorBuilder: (context, index) =>
          Divider(color: Colors.black, height: 1),
      itemCount: todoList.length,
      itemBuilder: (context, index) {
        if (index < todoList.length) {
          return _buildTodoItem(context, todoList[index], index);
        }
      },
    );
  }

  Widget _buildTodoItem(BuildContext context, Task todoItem, int index) {
    return new Dismissible(
        key: Key(todoItem.created),
        onDismissed: (DismissDirection dir) {
          _removeTodoItem(index);
        },
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            _removeTodoItem(index);
            // Scaffold.of(context).showSnackBar(SnackBar(
            //   content: Text(direction == DismissDirection.startToEnd
            //       ? '"${todoItem.name}" deleted.'
            //       : '"${todoItem.name}" marked as done and removed.'),
            //   // action: SnackBarAction(
            //   //     label: 'UNDO',
            //   //     // onPressed: () {
            //   //     //   setState(() => _addTodoItem(todoItem));
            //   //     // },
            // ));

            /// edit item
            return true;
          } else if (direction == DismissDirection.endToStart) {
            setState(() => _toggleItemCheckbox(index));

            /// delete
            return false;
          }
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
            leading: Padding(
                child: Opacity(
                  opacity: 0.4,
                  child: Icon(Icons.assignment_turned_in, size: 32),
                ),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0)),
            trailing: new Checkbox(
              value: todoItem.checked,
              onChanged: (bool value) {
                _toggleItemCheckbox(index);
              },
            ),
            title: Padding(
                child: new Text(todoItem.name),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0)),
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
            child: deleted.length > 0
                ? IconButton(
                    alignment: Alignment.centerLeft,
                    icon: Icon(
                      Icons.restore,
                      size: 36,
                    ),
                    onPressed: _restoreDeletedTasks,
                  )
                : null,
            padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
          ),
          Padding(
            child: IconButton(
              alignment: Alignment.centerRight,
              icon: Icon(
                Icons.delete_forever,
                size: 36,
              ),
              onPressed: () {
                if (todoList.toList().where((t) => t.checked).length > 0)
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
