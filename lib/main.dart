import 'package:agenda_estudos/view/home_screen.dart';
import 'package:flutter/material.dart';
import 'screens/configuracoes_screen.dart';

void main() {
  runApp(MyApp());
}
//

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Agenda de Estudos',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/configuracoes': (context) => ConfiguracoesScreen(),
      },
    );
  }
}
