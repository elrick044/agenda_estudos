import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/subject.dart';
import '../models/task.dart';
import '../services/data_service.dart';

class AddTaskScreen extends StatefulWidget {
  final Subject initialSubject;
  final List<Subject> subjects;

  const AddTaskScreen({
    Key? key,
    required this.initialSubject,
    required this.subjects,
  }) : super(key: key);

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late Subject _selectedSubject;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _priority = 2; // Default to medium priority

  @override
  void initState() {
    super.initState();
    _selectedSubject = widget.initialSubject;
    // Set deadline to tomorrow at 8:00 PM by default
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    _selectedDate = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
    _selectedTime = const TimeOfDay(hour: 20, minute: 0);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  DateTime _combineDateAndTime() {
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
  }

  void _saveTask() async {
    if (_formKey.currentState!.validate()) {
      final dataService = DataService();
      final deadline = _combineDateAndTime();

      final task = Task(
        id: dataService.generateId(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        subjectId: _selectedSubject.id,
        deadline: deadline,
        priority: _priority,
      );

      await dataService.addTask(task);
      Navigator.pop(context, true); // Return true to indicate task was added
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat.yMMMd().format(_selectedDate);
    final formattedTime = _selectedTime.format(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Tarefa'),
        backgroundColor: _selectedSubject.color,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um título';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Subject>(
                value: _selectedSubject,
                decoration: const InputDecoration(
                  labelText: 'Disciplina',
                  border: OutlineInputBorder(),
                ),
                items: widget.subjects.map((subject) {
                  return DropdownMenuItem<Subject>(
                    value: subject,
                    child: Row(
                      children: [
                        Icon(subject.icon, color: subject.color, size: 20),
                        const SizedBox(width: 8),
                        Text(subject.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedSubject = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Data',
                          border: OutlineInputBorder(),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(formattedDate),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Hora',
                          border: OutlineInputBorder(),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(formattedTime),
                            const Icon(Icons.access_time),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Prioridade:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<int>(
                      title: Row(
                        children: [
                          Icon(Icons.arrow_downward, color: Colors.green),
                          const SizedBox(width: 4),
                          const Text('Baixa'),
                        ],
                      ),
                      value: 1,
                      groupValue: _priority,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _priority = value;
                          });
                        }
                      },
                      activeColor: _selectedSubject.color,
                      dense: true,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<int>(
                      title: Row(
                        children: [
                          Icon(Icons.drag_handle, color: Colors.orange),
                          const SizedBox(width: 4),
                          const Text('Média'),
                        ],
                      ),
                      value: 2,
                      groupValue: _priority,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _priority = value;
                          });
                        }
                      },
                      activeColor: _selectedSubject.color,
                      dense: true,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<int>(
                      title: Row(
                        children: [
                          Icon(Icons.arrow_upward, color: Colors.red),
                          const SizedBox(width: 4),
                          const Text('Alta'),
                        ],
                      ),
                      value: 3,
                      groupValue: _priority,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _priority = value;
                          });
                        }
                      },
                      activeColor: _selectedSubject.color,
                      dense: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _saveTask,
                icon: const Icon(Icons.save),
                label: const Text('SALVAR TAREFA'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedSubject.color,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
