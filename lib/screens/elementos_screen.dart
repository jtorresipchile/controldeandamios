import 'package:flutter/material.dart';
import '../services/api.dart';
import '../widgets.dart';

class ElementosScreen extends StatefulWidget {
  final Perfil perfil;
  const ElementosScreen({super.key, required this.perfil});
  @override
  State<ElementosScreen> createState() => _ElementosScreenState();
}

class _ElementosScreenState extends State<ElementosScreen> {
  late Future<List<Row>> _f = Api.elementos();
  void _recargar() => setState(() => _f = Api.elementos());

  Future<void> _editar([Row? e]) async {
    final n = TextEditingController(text: e?['nombre']);
    final u = TextEditingController(text: e?['unidad'] ?? 'un');
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(e == null ? 'Nuevo elemento' : 'Editar elemento'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: n, decoration: const InputDecoration(labelText: 'Nombre (ej: Marco 1.0x1.5)')),
          TextField(controller: u, decoration: const InputDecoration(labelText: 'Unidad (un, m, kg...)')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Guardar')),
        ],
      ),
    );
    if (ok != true || n.text.trim().isEmpty) return;
    try {
      await Api.guardarElemento(e?['id'], n.text.trim(), u.text.trim());
      _recargar();
    } catch (x) {
      if (mounted) snack(context, 'Error: $x');
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin = widget.perfil.esAdmin;
    return Scaffold(
      floatingActionButton: admin ? FloatingActionButton(onPressed: _editar, child: const Icon(Icons.add)) : null,
      body: FutureBuilder<List<Row>>(
        future: _f,
        builder: (c, s) {
          if (!s.hasData) return Center(child: s.hasError ? Text('${s.error}') : const CircularProgressIndicator());
          final l = s.data!;
          if (l.isEmpty) return const Center(child: Text('Sin elementos'));
          return ListView.separated(
            itemCount: l.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) => ListTile(
              title: Text(l[i]['nombre']),
              subtitle: Text('Unidad: ${l[i]['unidad']}'),
              trailing: admin
                  ? Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(icon: const Icon(Icons.edit), onPressed: () => _editar(l[i])),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          if (!await confirmar(context, 'Â¿Eliminar "${l[i]['nombre']}"?')) return;
                          try {
                            await Api.borrarElemento(l[i]['id']);
                            _recargar();
                          } catch (_) {
                            if (mounted) snack(context, 'No se puede eliminar: tiene guÃ­as asociadas');
                          }
                        },
                      ),
                    ])
                  : null,
            ),
          );
        },
      ),
    );
  }
}