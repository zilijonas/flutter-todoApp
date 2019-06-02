import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_app/reorderableList/knoppReorderableList.dart';
import 'package:my_app/task.dart';

class Item extends StatelessWidget {
  Item(
      {this.data,
      this.isFirst,
      this.isLast,
      this.onRemoved,
      this.onChecked,
      this.onEdit});

  final Task data;
  final bool isFirst;
  final bool isLast;
  final Function onRemoved;
  final Function onChecked;
  final Function onEdit;

  Widget _buildChild(BuildContext context, ReorderableItemState state) {
    BoxDecoration decoration;

    if (state == ReorderableItemState.dragProxy ||
        state == ReorderableItemState.dragProxyFinished) {
      // slightly transparent background white dragging (just like on iOS)
      decoration = BoxDecoration(color: Color(0xD0FFFFFF));
    } else {
      bool placeholder = state == ReorderableItemState.placeholder;
      decoration = BoxDecoration(
          border: Border(
              top: isFirst && !placeholder
                  ? Divider.createBorderSide(context) //
                  : BorderSide.none,
              bottom: isLast && placeholder
                  ? BorderSide.none //
                  : Divider.createBorderSide(context)),
          color: placeholder ? null : Colors.white);
    }

    // For iOS dragging mdoe, there will be drag handle on the right that triggers
    // reordering; For android mode it will be just an empty container
    Widget dragHandle = ReorderableListener(
      child: Container(
        padding: EdgeInsets.only(right: 18.0, left: 18.0),
        color: Colors.white,
        child: Center(
          child: Icon(Icons.reorder, color: Color(0xFF888888)),
        ),
      ),
    );

    Duration itemAge = DateTime.now().difference(DateTime.parse(data.created));
    int days = itemAge.inDays;
    int hours = itemAge.inHours;
    int mins = itemAge.inMinutes;
    int secs = itemAge.inSeconds;
    String formattedTaskAge =
        'Created ${days > 0 ? days.toString() + ' days' : hours > 0 ? hours.toString() + ' hours' : mins > 0 ? mins.toString() + ' mins' : secs.toString() + ' seconds'} ago.';

    Row row = Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: ListTile(
            leading: Transform.scale(
              scale: 1.1,
              child: Checkbox(
                materialTapTargetSize: MaterialTapTargetSize.padded,
                activeColor: Colors.green[400],
                value: data.checked,
                onChanged: (bool val) {
                  onChecked(data.idx);
                },
              ),
            ),
            subtitle: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Container(
                    constraints: BoxConstraints(maxHeight: double.infinity),
                    padding: EdgeInsets.only(top: 20, bottom: 10),
                    child: Text(
                      data.name,
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ),
                ),
                Container(
                    padding: EdgeInsets.only(bottom: 10),
                    child:
                        Text(formattedTaskAge, style: TextStyle(fontSize: 12)))
              ],
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 0),
            onTap: () => onChecked(data.idx),
          ),
        ),
        // Triggers the reordering
        dragHandle,
      ],
    );

    Dismissible dismissibleRow = Dismissible(
      key: Key(data.created),
      confirmDismiss: (DismissDirection dir) async {
        if (dir == DismissDirection.startToEnd) {
          return true;
        }
        onEdit(data);
        return false;
      },
      onDismissed: (DismissDirection dir) {
        onRemoved(data.idx);
      },
      child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
                left: Divider.createBorderSide(context),
                right: Divider.createBorderSide(context)),
          ),
          child: row),
      background: Container(
        color: Colors.grey[100],
        child: Icon(Icons.delete, color: Colors.red, size: 32),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 15),
      ),
      secondaryBackground: Container(
        color: Colors.grey[100],
        child: Icon(Icons.mode_edit, color: Colors.blue, size: 32),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 15),
      ),
    );

    Widget content = Container(
      decoration: decoration,
      child: SafeArea(
          top: false,
          bottom: false,
          child: Opacity(
            // hide content for placeholder
            opacity: state == ReorderableItemState.placeholder ? 0.0 : 1.0,
            child: IntrinsicHeight(
              child: dismissibleRow,
            ),
          )),
    );

    return content;
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableItem(
        key: ValueKey(data.idx), //
        childBuilder: _buildChild);
  }
}
