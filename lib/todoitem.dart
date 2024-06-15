import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proje_ilk/constants/task_type.dart';
import 'package:proje_ilk/model/task.dart';

class TodoItem extends StatefulWidget {
  const TodoItem({Key? key, required this.task, required this.onTaskComplete});
  final Task task;
  final VoidCallback onTaskComplete;

  @override
  State<TodoItem> createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: widget.task.isCompleted ? Colors.grey : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.task.title,
                        style: TextStyle(
                          decoration: widget.task.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          fontWeight: FontWeight.bold,
                          fontSize: 21,
                        ),
                      ),
                      Text(
                        widget.task.description,
                        style: TextStyle(
                          decoration: widget.task.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      if (widget.task.dateTime != null)
                        Text(
                          DateFormat('d MMMM yyyy - HH:mm', 'tr_TR').format(widget.task.dateTime!),
                          style: TextStyle(
                            decoration: widget.task.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
                Checkbox(
                  value: widget.task.isCompleted,
                  onChanged: (val) {
                    setState(() {
                      widget.task.isCompleted = val!;
                      widget.onTaskComplete();
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
