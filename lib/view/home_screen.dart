import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:agenda_estudos/view/drawer_widget.dart';
import '../model/tarefa.dart';
import '../widget/tarefa_card.dart';

enum ViewType { lista, calendario }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Tarefa> tarefas = [];
  ViewType view = ViewType.lista;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  void _adicionarTarefa() {
    String titulo = '';
    String descricao = '';
    DateTime dataSelecionada = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Nova Tarefa'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Título'),
                  onChanged: (value) => titulo = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Descrição'),
                  onChanged: (value) => descricao = value,
                ),
                ElevatedButton(
                  child: Text('Selecionar Data'),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: dataSelecionada,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() {
                        dataSelecionada = date;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Salvar'),
              onPressed: () {
                if (titulo.isNotEmpty) {
                  setState(() {
                    tarefas.add(
                      Tarefa(
                        titulo: titulo,
                        descricao: descricao,
                        data: dataSelecionada,
                      ),
                    );
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _marcarComoConcluida(int index) {
    setState(() {
      tarefas[index].concluida = !tarefas[index].concluida;
    });
  }

  void _removerTarefa(int index) {
    setState(() {
      tarefas.removeAt(index);
    });
  }

  List<Tarefa> _tarefasDoDia(DateTime dia) {
    return tarefas
        .where(
          (t) =>
              t.data.year == dia.year &&
              t.data.month == dia.month &&
              t.data.day == dia.day,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    List<Tarefa> tarefasParaMostrar;
    if (view == ViewType.lista) {
      tarefasParaMostrar = List.from(tarefas);
      tarefasParaMostrar.sort((a, b) => a.data.compareTo(b.data));
    } else {
      tarefasParaMostrar = _tarefasDoDia(_selectedDay ?? _focusedDay);
    }

    return Scaffold(
      drawer: DrawerWidget(currentRoute: '/',),
      appBar: AppBar(
        title: Text('Agenda de Estudos'),
        actions: [
          IconButton(
            icon: Icon(
              view == ViewType.lista ? Icons.calendar_month : Icons.list,
            ),
            onPressed: () {
              setState(() {
                view =
                    view == ViewType.lista
                        ? ViewType.calendario
                        : ViewType.lista;
              });
            },
          ),
        ],
        backgroundColor: Colors.red,
      ),
      body:
          view == ViewType.lista
              ? tarefasParaMostrar.isEmpty ? Center(child: Text("Nenhuma tarefa"),) : ListView.builder(
            itemCount: tarefasParaMostrar.length,
            itemBuilder:
                (ctx, index) => TarefaCard(
              tarefa: tarefasParaMostrar[index],
              onCheck:
                  () => _marcarComoConcluida(
                tarefas.indexOf(tarefasParaMostrar[index]),
              ),
              onDelete:
                  () => _removerTarefa(
                tarefas.indexOf(tarefasParaMostrar[index]),
              ),
            ),
          )
              : Column(
                children: [
                  TableCalendar(
                    firstDay: DateTime(2020),
                    lastDay: DateTime(2100),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                    onDaySelected: (selected, focused) {
                      setState(() {
                        _selectedDay = selected;
                        _focusedDay = focused;
                      });
                    },
                    calendarFormat: CalendarFormat.month,
                  ),
                  Expanded(
                    child:
                        tarefasParaMostrar.isEmpty
                            ? Center(child: Text('Nenhuma tarefa para o dia.'))
                            : ListView.builder(
                              itemCount: tarefasParaMostrar.length,
                              itemBuilder:
                                  (ctx, index) => TarefaCard(
                                    tarefa: tarefasParaMostrar[index],
                                    onCheck:
                                        () => _marcarComoConcluida(
                                          tarefas.indexOf(
                                            tarefasParaMostrar[index],
                                          ),
                                        ),
                                    onDelete:
                                        () => _removerTarefa(
                                          tarefas.indexOf(
                                            tarefasParaMostrar[index],
                                          ),
                                        ),
                                  ),
                            ),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _adicionarTarefa,
        child: Icon(Icons.add),
      ),
    );
  }
}
