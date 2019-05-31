import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'task.dart';
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart';

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
        todoList.sort((a, b) => a.id.compareTo(b.id));
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

  // Widget _buildTodoList() {
  //   return ListView.separated(
  //     separatorBuilder: (context, index) =>
  //         Divider(color: Colors.black, height: 1),
  //     itemCount: todoList.length,
  //     itemBuilder: (context, index) {
  //       if (index < todoList.length) {
  //         return _buildTodoItem(context, todoList[index], index);
  //       }
  //     },
  //   );
  // }

  Widget _buildTodoItem(BuildContext context, Task todoItem, int index) {
    return Dismissible(
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
          child: Icon(Icons.delete, color: Colors.red, size: 32),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 15),
        ),
        secondaryBackground: Container(
          child: Icon(Icons.check_circle, color: Colors.green, size: 32),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 15),
        ),
        child: Card(
            elevation: 2,
            child: ListTile(
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
                // trailing: Checkbox(
                //   value: todoItem.checked,
                //   activeColor: Colors.green,
                //   onChanged: (bool value) {
                //     _toggleItemCheckbox(index);
                //   },
                // ),
                title: Padding(
                    child: Text(todoItem.name),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 0)),
                subtitle: Text(DateFormat('yyyy.MM.dd HH:mm')
                    .format(DateTime.parse(todoItem.created))
                    .toString()),
                onTap: () => _toggleItemCheckbox(index))));
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
      // body: Container(
      //     child: Stack(children: <Widget>[
      //   Positioned(
      //     child: _buildTodoList(),
      //   ),
      // ])),
      body: Scrollbar(
        child: ReorderableListView(
          // header: Padding(
          //     padding: const EdgeInsets.all(8.0),
          //     child: Text('Header of the list',
          //         style: Theme.of(context).textTheme.headline)),
          onReorder: _onReorder,
          // reverse: _reverse,
          scrollDirection: Axis.vertical,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          children: todoList
              .map<Widget>((task) =>
                  _buildTodoItem(context, task, todoList.indexOf(task)))
              .toList(),
        ),
      ),
      // ---

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
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final Task item = todoList.removeAt(oldIndex);
      todoList.insert(newIndex, item);
      todoList[newIndex].id = newIndex;
      todoList[oldIndex].id = oldIndex;
    });
    _setData();
  }
}
