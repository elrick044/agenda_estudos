import 'package:flutter/material.dart';
import 'package:agenda_estudos/view/drawer_widget.dart';

class ConfiguracoesScreen extends StatelessWidget {
  const ConfiguracoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerWidget(currentRoute: '/configuracoes',),
      appBar: AppBar(
        title: Text('Configurações'),
      ),
      body: Center(
        child: Text('Tela de configurações vazia'),
      ),
    );
  }
}
