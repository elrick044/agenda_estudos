import 'package:flutter/material.dart';
import '../models/subject.dart';
import '../screens/calendar_screen.dart';

class CustomDrawer extends StatelessWidget {
  final List<Subject> subjects;
  final Subject selectedSubject;
  final Function(Subject) onSubjectSelected;

  const CustomDrawer({
    Key? key,
    required this.subjects,
    required this.selectedSubject,
    required this.onSubjectSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            child: Image.asset('assets/images/agenda-image.png'),
          ),
          Expanded(
            child: ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'DISCIPLINAS',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                ...subjects.map((subject) => SubjectListItem(
                  subject: subject,
                  isSelected: subject.id == selectedSubject.id,
                  onTap: () => onSubjectSelected(subject),
                )),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Calendário'),
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CalendarScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Versão 1.0',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class SubjectListItem extends StatelessWidget {
  final Subject subject;
  final bool isSelected;
  final VoidCallback onTap;

  const SubjectListItem({
    Key? key,
    required this.subject,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        subject.icon,
        color: subject.color,
      ),
      title: Text(subject.name),
      selected: isSelected,
      selectedTileColor: subject.color.withOpacity(0.1),
      onTap: onTap,
    );
  }
}
