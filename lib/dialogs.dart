import 'package:flutter/material.dart';

void promptRestoreDeletedTasks(
    BuildContext context, int deletedLength, Function _restoreDeletedTasks) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Restore cleared tasks?'),
          content: Text('Your $deletedLength cleared tasks will be restored.'),
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

void promptClearDoneTasks(
    BuildContext context, int checkedLength, Function _removeCheckedItems) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Clear all checked tasks?'),
          content: Text(
              'You have selected $checkedLength ${checkedLength > 1 ? 'tasks' : 'task'} to clear.'),
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

void promptNoTasksToClear(BuildContext context) {
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

void promptSortList(
  BuildContext context,
  Function _sortByChecked,
  Function _sortByCreated,
) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sort list'),
          content: Text('Select property by which should list be sorted.'),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            FlatButton(
              child: Text(
                'By checked',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              onPressed: () {
                _sortByChecked();
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                'By created',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              onPressed: () {
                _sortByCreated();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      });
}
