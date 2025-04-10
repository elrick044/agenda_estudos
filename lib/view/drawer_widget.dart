import 'package:flutter/material.dart';
import '../screens/configuracoes_screen.dart';

class DrawerWidget extends StatelessWidget {
  final String currentRoute;

  const DrawerWidget({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Início'),
            selected: currentRoute == '/',
            onTap: () {
              Navigator.of(context).pop();
              if (currentRoute != '/') {
                Navigator.of(context).pushReplacementNamed('/');
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Configurações'),
            selected: currentRoute == '/configuracoes',
            onTap: () {
              Navigator.of(context).pop();
              if (currentRoute != '/configuracoes') {
                Navigator.of(context).pushReplacementNamed('/configuracoes');
              }
            },
          ),
        ],
      ),
    );
  }
}
