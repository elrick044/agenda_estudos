class Tarefa {
  String titulo;
  String descricao;
  DateTime data;
  bool concluida;

  Tarefa({
    required this.titulo,
    required this.descricao,
    required this.data,
    this.concluida = false,
  });
}
