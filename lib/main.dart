import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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

class TodoListState extends State<TodoList> {
  List<String> _todoItems = [];
  List<bool> checkedItems = [];

  void _addTodoItem(String task) {
    if (task.length > 0) {
      setState(() => _todoItems.add(task));
      setState(() => checkedItems.add(false));
    }
  }

  void _removeTodoItem(int index) {
    setState(() => _todoItems.removeAt(index));
    setState(() => checkedItems.removeAt(index));
  }

  void _markAsDoneItem(int index) {
    setState(() => checkedItems[index] = true);
  }

  void _removeCheckedItems() {
    var removedItems = 0;
    checkedItems.toList().asMap().forEach((index, checked) => {
          if (checked) {_removeTodoItem(index - removedItems), removedItems++}
        });
  }

  void _promptMarkAsDoneItem(int index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text('Mark "${_todoItems[index]}" as done?'),
            actions: <Widget>[
              new FlatButton(
                child: new Text('CANCEL'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              new FlatButton(
                  child: new Text('MARK AS DONE'),
                  onPressed: () {
                    _markAsDoneItem(index);
                    Navigator.of(context).pop();
                  })
            ],
          );
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
    return new ListView.builder(
      itemBuilder: (context, index) {
        if (index < _todoItems.length) {
          return _buildTodoItem(_todoItems[index], index);
        }
      },
    );
  }

  Widget _buildTodoItem(String todoText, int index) {
    return new Center(
        child: new Card(
            child: ListTile(
                leading: new Checkbox(
                  value: checkedItems[index],
                  onChanged: (bool value) {
                    setState(() {
                      checkedItems[index] = !checkedItems[index];
                    });
                  },
                ),
                title: new Text(todoText),
                subtitle: new Text('Task ${index + 1}'),
                onTap: () => _promptMarkAsDoneItem(index))));
  }

  void _pushAddTodoScreen() {
    Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
      return new Scaffold(
          appBar: new AppBar(title: new Text('Add new task')),
          body: new TextField(
            autofocus: true,
            autocorrect: true,
            onSubmitted: (val) {
              _addTodoItem(val);
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
                  margin: const EdgeInsets.only(bottom: 25.0),
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
