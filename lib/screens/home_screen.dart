import 'package:flutter/material.dart';
import '../services/api.dart';
import '../widgets.dart';
import 'movimientos_screen.dart';
import 'elementos_screen.dart';
import 'informe_screen.dart';
import 'usuarios_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _i = 0;
  late Future<Perfil?> _perfil = Api.perfilActual();

  @override
  Widget build(BuildContext context) => FutureBuilder<Perfil?>(
        future: _perfil,
        builder: (c, s) {
          if (s.connectionState != ConnectionState.done) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          final p = s.data;
          if (p == null) {
            return Scaffold(
              bottomNavigationBar: const AppFooter(),
              body: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('Tu usuario no tiene perfil habilitado.'),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: () => sb.auth.signOut(), child: const Text('Salir')),
                ]),
              ),
            );
          }
          final tabs = <(String, IconData, Widget)>[
            ('GuÃ­as', Icons.receipt_long, MovimientosScreen(perfil: p)),
            ('Elementos', Icons.inventory_2, ElementosScreen(perfil: p)),
            ('Informe', Icons.bar_chart, const InformeScreen()),
            if (p.esAdmin) ('Usuarios', Icons.people, UsuariosScreen(perfil: p)),
          ];
          if (_i >= tabs.length) _i = 0;
          return Scaffold(
            appBar: AppBar(
              title: Text('Andamios SEPCO Â· ${tabs[_i].$1}'),
              actions: [
                Center(child: Text('${p.nombre} (${p.rol})')),
                IconButton(icon: const Icon(Icons.logout), tooltip: 'Salir', onPressed: () => sb.auth.signOut()),
              ],
            ),
            body: tabs[_i].$3,
            bottomNavigationBar: Column(mainAxisSize: MainAxisSize.min, children: [
              NavigationBar(
                selectedIndex: _i,
                onDestinationSelected: (v) => setState(() => _i = v),
                destinations: [for (final t in tabs) NavigationDestination(icon: Icon(t.$2), label: t.$1)],
              ),
              const AppFooter(),
            ]),
          );
        },
      );
}