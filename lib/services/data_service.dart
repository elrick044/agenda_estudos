import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/subject.dart';
import '../models/task.dart';

class DataService {
  static const String _subjectsKey = 'subjects';
  static const String _tasksKey = 'tasks';
  static const String _firstLaunchKey = 'first_launch';
  static final DataService _instance = DataService._internal();
  late SharedPreferences _prefs;
  final _uuid = Uuid();

  // Singleton pattern
  factory DataService() {
    return _instance;
  }

  DataService._internal();

  // Initialize the service
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = _prefs.getBool(_firstLaunchKey) ?? true;

    if (isFirstLaunch) {
      await _initSampleData();
      await _prefs.setBool(_firstLaunchKey, false);
    }
  }

  // Get all subjects
  Future<List<Subject>> getSubjects() async {
    final jsonStr = _prefs.getStringList(_subjectsKey) ?? [];
    return jsonStr.map((str) => Subject.fromJson(jsonDecode(str))).toList();
  }

  // Save all subjects
  Future<void> saveSubjects(List<Subject> subjects) async {
    final jsonStr = subjects.map((subject) => jsonEncode(subject.toJson())).toList();
    await _prefs.setStringList(_subjectsKey, jsonStr);
  }

  // Add a new subject
  Future<void> addSubject(Subject subject) async {
    final subjects = await getSubjects();
    subjects.add(subject);
    await saveSubjects(subjects);
  }

  // Delete a subject
  Future<void> deleteSubject(String subjectId) async {
    final subjects = await getSubjects();
    subjects.removeWhere((subject) => subject.id == subjectId);
    await saveSubjects(subjects);

    // Also delete all tasks for this subject
    final tasks = await getTasks();
    tasks.removeWhere((task) => task.subjectId == subjectId);
    await saveTasks(tasks);
  }

  // Get all tasks
  Future<List<Task>> getTasks() async {
    final jsonStr = _prefs.getStringList(_tasksKey) ?? [];
    return jsonStr.map((str) => Task.fromJson(jsonDecode(str))).toList();
  }

  // Save all tasks
  Future<void> saveTasks(List<Task> tasks) async {
    final jsonStr = tasks.map((task) => jsonEncode(task.toJson())).toList();
    await _prefs.setStringList(_tasksKey, jsonStr);
  }

  // Add a new task
  Future<void> addTask(Task task) async {
    final tasks = await getTasks();
    tasks.add(task);
    await saveTasks(tasks);
  }

  // Update a task
  Future<void> updateTask(Task updatedTask) async {
    final tasks = await getTasks();
    final index = tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      tasks[index] = updatedTask;
      await saveTasks(tasks);
    }
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    final tasks = await getTasks();
    tasks.removeWhere((task) => task.id == taskId);
    await saveTasks(tasks);
  }

  // Get tasks for a specific subject
  Future<List<Task>> getTasksBySubject(String subjectId) async {
    final tasks = await getTasks();
    return tasks.where((task) => task.subjectId == subjectId).toList();
  }

  // Get tasks for a specific date
  Future<List<Task>> getTasksByDate(DateTime date) async {
    final tasks = await getTasks();
    return tasks.where((task) {
      return task.deadline.year == date.year &&
          task.deadline.month == date.month &&
          task.deadline.day == date.day;
    }).toList();
  }

  // Toggle task completion status
  Future<void> toggleTaskCompletion(String taskId) async {
    final tasks = await getTasks();
    final index = tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      tasks[index] = tasks[index].copyWith(isCompleted: !tasks[index].isCompleted);
      await saveTasks(tasks);
    }
  }

  // Generate a new UUID
  String generateId() {
    return _uuid.v4();
  }

  // Initialize with sample data
  Future<void> _initSampleData() async {
    final subjects = [
      Subject(
        id: _uuid.v4(),
        name: 'Matemática',
        color: Colors.blue,
        icon: Icons.calculate,
      ),
      Subject(
        id: _uuid.v4(),
        name: 'Português',
        color: Colors.red,
        icon: Icons.book,
      ),
      Subject(
        id: _uuid.v4(),
        name: 'História',
        color: Colors.brown,
        icon: Icons.history_edu,
      ),
      Subject(
        id: _uuid.v4(),
        name: 'Ciências',
        color: Colors.green,
        icon: Icons.science,
      ),
    ];

    await saveSubjects(subjects);

    final now = DateTime.now();
    final tasks = [
      Task(
        id: _uuid.v4(),
        title: 'Resolver exercícios de álgebra',
        description: 'Páginas 45-48 do livro de matemática',
        subjectId: subjects[0].id,
        deadline: now.add(Duration(days: 2)),
        priority: 2,
      ),
      Task(
        id: _uuid.v4(),
        title: 'Redação sobre meio ambiente',
        description: 'Escrever redação de 30 linhas sobre sustentabilidade',
        subjectId: subjects[1].id,
        deadline: now.add(Duration(days: 5)),
        priority: 3,
      ),
      Task(
        id: _uuid.v4(),
        title: 'Resumo sobre Revolução Francesa',
        description: 'Preparar resumo para apresentação oral',
        subjectId: subjects[2].id,
        deadline: now.add(Duration(days: 1)),
        priority: 1,
      ),
    ];

    await saveTasks(tasks);
  }
}
