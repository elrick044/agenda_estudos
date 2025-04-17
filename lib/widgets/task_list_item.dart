import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/subject.dart';

class TaskListItem extends StatelessWidget {
  final Task task;
  final Subject subject;
  final VoidCallback onToggleComplete;
  final VoidCallback onDelete;

  const TaskListItem({
    Key? key,
    required this.task,
    required this.subject,
    required this.onToggleComplete,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      child: InkWell(
        onLongPress: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Excluir Tarefa', style: TextStyle(fontFamily: 'schyler'),),
              content: const Text('Tem certeza que deseja excluir esta tarefa?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCELAR'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onDelete();
                  },
                  child: const Text('EXCLUIR'),
                ),
              ],
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: task.isCompleted,
                    activeColor: subject.color,
                    onChanged: (_) => onToggleComplete(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: task.isCompleted
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),
                        if (task.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            task.description,
                            style: TextStyle(
                              color: task.isCompleted
                                  ? Colors.grey
                                  : Colors.black87,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    backgroundColor: subject.color.withOpacity(0.1),
                    label: Text(
                      subject.name,
                      style: TextStyle(color: subject.color),
                    ),
                    avatar: Icon(
                      subject.icon,
                      size: 16,
                      color: subject.color,
                    ),
                  ),
                  Chip(
                    backgroundColor: _getPriorityColor(task.priority).withOpacity(0.1),
                    label: Text(
                      task.priorityText,
                      style: TextStyle(
                        color: _getPriorityColor(task.priority),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: _getDeadlineColor(task),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    task.formattedDeadline,
                    style: TextStyle(
                      color: _getDeadlineColor(task),
                      fontWeight: task.isDueSoon || task.isOverdue
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  if (task.isOverdue) ...[
                    const SizedBox(width: 8),
                    const Text(
                      'ATRASADA',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ] else if (task.isDueSoon) ...[
                    const SizedBox(width: 8),
                    const Text(
                      'EM BREVE',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getDeadlineColor(Task task) {
    if (task.isCompleted) {
      return Colors.grey;
    } else if (task.isOverdue) {
      return Colors.red;
    } else if (task.isDueSoon) {
      return Colors.orange;
    } else {
      return Colors.black54;
    }
  }
}
