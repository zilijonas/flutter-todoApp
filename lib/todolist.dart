import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_app/editTodoScreen.dart';
import 'package:my_app/item.dart';
import 'package:my_app/reorderableList/knoppReorderableList.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'addTodoScreen.dart';
import 'dialogs.dart';
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
    // prefs.clear();
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
        // todoList.sort((a, b) => a.idx.compareTo(b.idx));
      });
      _setData();
    }
  }

  void _editTodoItem(val, taskIndex) {
    setState(() => todoList[taskIndex].name = val);
    _setData();
  }

  void _removeTodoItem(int index) {
    var task = todoList[index];
    deleted.add(task);
    setState(() {
      todoList.removeAt(index);
      _resetTodolistIndexes();
    });
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
    setState(() {
      deleted = [];
      // todoList.sort((a, b) => a.idx.compareTo(b.idx));
      _resetTodolistIndexes();
    });
  }

  void _resetTodolistIndexes() {
    todoList.asMap().forEach((index, item) => item.idx = index);
  }

  void _pushAddTodoScreen() {
    Navigator.of(context).push(addTodoScreen(_addTodoItem, todoList.length));
  }

  void _pushEditTodoScreen(Task task) {
    Navigator.of(context)
        .push(editTodoScreen(task.name, task.idx, _editTodoItem));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
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
                    onPressed: () {
                      promptRestoreDeletedTasks(
                          context, deleted.length, _restoreDeletedTasks);
                    },
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
                  promptClearDoneTasks(
                      context,
                      todoList.where((t) => t.checked).length,
                      _removeCheckedItems);
                } else {
                  promptNoTasksToClear(context);
                }
              },
            ),
            padding: const EdgeInsets.fromLTRB(0, 0, 18, 0),
          )
        ],
      ),
      body: ReorderableList(
          onReorder: _reorderCallback,
          onReorderDone: (Key key) {
            setState(() => _resetTodolistIndexes());
            _setData();
          },
          child: CustomScrollView(
            slivers: <Widget>[
              SliverPadding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return Item(
                            data: todoList[index],
                            isFirst: index == 0,
                            isLast: index == todoList.length - 1,
                            onRemoved: _removeTodoItem,
                            onChecked: _toggleItemCheckbox,
                            onEdit: _pushEditTodoScreen);
                      },
                      childCount: todoList.length,
                    ),
                  )),
            ],
          )),
      floatingActionButton: FloatingActionButton(
          onPressed: _pushAddTodoScreen,
          tooltip: 'Add task',
          backgroundColor: Colors.indigoAccent,
          child: Icon(
            Icons.add,
          )),
    );
  }

  int _indexOfKey(Key key) {
    return todoList.indexWhere((t) => ValueKey(t.idx) == key);
  }

  bool _reorderCallback(Key item, Key newPosition) {
    int draggingIndex = _indexOfKey(item);
    int newPositionIndex = _indexOfKey(newPosition);

    // Uncomment to allow only even target reorder possition
    // if (newPositionIndex % 2 == 1)
    //   return false;

    final Task draggedItem = todoList[draggingIndex];
    setState(() {
      // debugPrint("Reordering ${item} -> $newPosition");
      todoList.removeAt(draggingIndex);
      todoList.insert(newPositionIndex, draggedItem);
    });
    return true;
  }
}
