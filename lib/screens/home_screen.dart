import 'package:flutter/material.dart';
import '../models/subject.dart';
import '../models/task.dart';
import '../services/data_service.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/task_list_item.dart';
import 'add_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DataService _dataService = DataService();
  List<Subject> _subjects = [];
  List<Task> _tasks = [];
  late Subject _selectedSubject;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    await _dataService.init();
    final subjects = await _dataService.getSubjects();

    if (subjects.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final selectedSubject = subjects[0]; // Default to first subject
    final tasks = await _dataService.getTasksBySubject(selectedSubject.id);

    setState(() {
      _subjects = subjects;
      _selectedSubject = selectedSubject;
      _tasks = tasks;
      _isLoading = false;
    });
  }

  Future<void> _selectSubject(Subject subject) async {
    setState(() {
      _isLoading = true;
    });

    final tasks = await _dataService.getTasksBySubject(subject.id);

    setState(() {
      _selectedSubject = subject;
      _tasks = tasks;
      _isLoading = false;
    });

    Navigator.pop(context); // Close drawer
  }

  Future<void> _toggleTaskCompletion(String taskId) async {
    await _dataService.toggleTaskCompletion(taskId);
    _refreshTasks();
  }

  Future<void> _deleteTask(String taskId) async {
    await _dataService.deleteTask(taskId);
    _refreshTasks();
  }

  Future<void> _refreshTasks() async {
    final tasks = await _dataService.getTasksBySubject(_selectedSubject.id);
    setState(() {
      _tasks = tasks;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Carregando...'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_subjects.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Agenda de Estudos', style: TextStyle(fontFamily: 'Schuyler'),),
        ),
        body: const Center(
          child: Text('Nenhuma disciplina encontrada.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(_selectedSubject.icon),
            const SizedBox(width: 8),
            Text(_selectedSubject.name),
          ],
        ),
        backgroundColor: _selectedSubject.color,
      ),
      drawer: CustomDrawer(
        subjects: _subjects,
        selectedSubject: _selectedSubject,
        onSubjectSelected: _selectSubject,
      ),
      body: _tasks.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 80,
              color: _selectedSubject.color.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma tarefa para ${_selectedSubject.name}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Adicione tarefas usando o botão abaixo',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return TaskListItem(
            task: task,
            subject: _selectedSubject,
            onToggleComplete: () => _toggleTaskCompletion(task.id),
            onDelete: () => _deleteTask(task.id),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _selectedSubject.color,
        child: const Icon(Icons.add),
        onPressed: () async {
          final added = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => AddTaskScreen(
                initialSubject: _selectedSubject,
                subjects: _subjects,
              ),
            ),
          );

          if (added == true) {
            _refreshTasks();
          }
        },
      ),
    );
  }
}
