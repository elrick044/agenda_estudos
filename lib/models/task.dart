import 'package:intl/intl.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final String subjectId;
  final DateTime deadline;
  final int priority; // 1-3: Low, Medium, High
  final bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.subjectId,
    required this.deadline,
    required this.priority,
    this.isCompleted = false,
  });

  // Convert Task to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'subjectId': subjectId,
      'deadline': deadline.toIso8601String(),
      'priority': priority,
      'isCompleted': isCompleted,
    };
  }

  // Create Task from JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      subjectId: json['subjectId'],
      deadline: DateTime.parse(json['deadline']),
      priority: json['priority'],
      isCompleted: json['isCompleted'],
    );
  }

  // Create a copy of the task with some changes
  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? subjectId,
    DateTime? deadline,
    int? priority,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      subjectId: subjectId ?? this.subjectId,
      deadline: deadline ?? this.deadline,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // Format the deadline
  String get formattedDeadline {
    return DateFormat('dd/MM/yyyy - HH:mm').format(deadline);
  }

  // Check if task is due soon (within 24 hours)
  bool get isDueSoon {
    final now = DateTime.now();
    final difference = deadline.difference(now).inHours;
    return difference > 0 && difference <= 24;
  }

  // Check if task is overdue
  bool get isOverdue {
    final now = DateTime.now();
    return deadline.isBefore(now) && !isCompleted;
  }

  // Get priority text
  String get priorityText {
    switch (priority) {
      case 1:
        return 'Baixa';
      case 2:
        return 'Média';
      case 3:
        return 'Alta';
      default:
        return 'Média';
    }
  }
}
