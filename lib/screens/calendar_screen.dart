import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../models/subject.dart';
import '../services/data_service.dart';
import '../widgets/task_list_item.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  final DataService _dataService = DataService();
  List<Task> _selectedDayTasks = [];
  List<Subject> _subjects = [];
  Map<DateTime, List<Task>> _events = {};
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
    final tasks = await _dataService.getTasks();
    final subjects = await _dataService.getSubjects();
    final events = _groupTasksByDay(tasks);

    setState(() {
      _events = events;
      _subjects = subjects;
      _selectedDayTasks = _getTasksForDay(_selectedDay);
      _isLoading = false;
    });
  }

  Map<DateTime, List<Task>> _groupTasksByDay(List<Task> tasks) {
    Map<DateTime, List<Task>> taskMap = {};
    for (var task in tasks) {
      final date = DateTime(task.deadline.year, task.deadline.month, task.deadline.day);
      if (taskMap[date] == null) taskMap[date] = [];
      taskMap[date]!.add(task);
    }
    return taskMap;
  }

  List<Task> _getTasksForDay(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    return _events[date] ?? [];
  }

  Subject _getSubjectById(String id) {
    return _subjects.firstWhere(
          (subject) => subject.id == id,
      orElse: () => Subject(
        id: 'default',
        name: 'Desconhecido',
        color: Colors.grey,
        icon: Icons.help_outline,
      ),
    );
  }

  Future<void> _toggleTaskCompletion(String taskId) async {
    await _dataService.toggleTaskCompletion(taskId);
    _loadData();
  }

  Future<void> _deleteTask(String taskId) async {
    await _dataService.deleteTask(taskId);
    _loadData();
  }

  bool _hasTasksOnDay(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    return _events.containsKey(date) && _events[date]!.isNotEmpty;
  }

  int _getTaskCount(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    return _events[date]?.length ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendário de Tarefas'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            eventLoader: (day) {
              return _getTasksForDay(day);
            },
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _selectedDayTasks = _getTasksForDay(selectedDay);
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarStyle: CalendarStyle(
              markersMaxCount: 3,
              markersAlignment: Alignment.bottomRight,
              markerDecoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return const SizedBox.shrink();

                return Positioned(
                  right: 1,
                  bottom: 1,
                  child: Container(
                    padding: const EdgeInsets.all(2.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).primaryColor,
                    ),
                    child: Text(
                      '${events.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.0,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8.0),
                Text(
                  DateFormat.yMMMMd().format(_selectedDay),
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 24.0),
          Expanded(
            child: _selectedDayTasks.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_available,
                    size: 80,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Nenhuma tarefa para este dia',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: _selectedDayTasks.length,
              itemBuilder: (context, index) {
                final task = _selectedDayTasks[index];
                final subject = _getSubjectById(task.subjectId);
                return TaskListItem(
                  task: task,
                  subject: subject,
                  onToggleComplete: () => _toggleTaskCompletion(task.id),
                  onDelete: () => _deleteTask(task.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
