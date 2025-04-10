import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/tarefa.dart';

class TarefaCard extends StatelessWidget {
  final Tarefa tarefa;
  final VoidCallback onCheck;
  final VoidCallback onDelete;

  const TarefaCard({super.key, required this.tarefa, required this.onCheck, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ListTile(
        leading: Checkbox(
          value: tarefa.concluida,
          onChanged: (value) => onCheck(),
        ),
        title: Text(
          tarefa.titulo,
          style: TextStyle(
            decoration: tarefa.concluida ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text('${tarefa.descricao}\n${DateFormat('dd/MM/yyyy').format(tarefa.data)}'),
        isThreeLine: true,
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
