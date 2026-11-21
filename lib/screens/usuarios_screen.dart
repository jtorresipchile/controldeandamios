import 'package:flutter/material.dart';
import '../services/api.dart';
import '../widgets.dart';

class UsuariosScreen extends StatefulWidget {
  final Perfil perfil;
  const UsuariosScreen({super.key, required this.perfil});
  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  late Future<List<Perfil>> _f = Api.usuarios();
  void _recargar() => setState(() => _f = Api.usuarios());

  Future<void> _editar([Perfil? u]) async {
    final email = TextEditingController(text: u?.email);
    final nombre = TextEditingController(text: u?.nombre);
    final pass = TextEditingController();
    String rol = u?.rol ?? 'bodega';
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, set) => AlertDialog(
          title: Text(u == null ? 'Nuevo usuario' : 'Editar usuario'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: nombre, decoration: const InputDecoration(labelText: 'Nombre')),
            TextField(controller: email, enabled: u == null, decoration: const InputDecoration(labelText: 'Correo (usuario)')),
            if (u == null) TextField(controller: pass, obscureText: true, decoration: const InputDecoration(labelText: 'ContraseÃ±a (mÃ­n. 6)')),
            DropdownButtonFormField<String>(
              value: rol,
              decoration: const InputDecoration(labelText: 'Rol'),
              items: const [
                DropdownMenuItem(value: 'admin', child: Text('Administrador')),
                DropdownMenuItem(value: 'bodega', child: Text('Usuario bodega')),
              ],
              onChanged: (v) => set(() => rol = v!),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')),
            FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Guardar')),
          ],
        ),
      ),
    );
    if (ok != true) return;
    try {
      if (u == null) {
        await Api.crearUsuario(email.text.trim(), pass.text, nombre.text.trim(), rol);
      } else {
        await Api.actualizarUsuario(u.id, nombre.text.trim(), rol);
      }
      _recargar();
    } catch (e) {
      if (mounted) snack(context, 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        floatingActionButton: FloatingActionButton(onPressed: _editar, child: const Icon(Icons.person_add)),
        body: FutureBuilder<List<Perfil>>(
          future: _f,
          builder: (c, s) {
            if (!s.hasData) return Center(child: s.hasError ? Text('${s.error}') : const CircularProgressIndicator());
            final l = s.data!;
            return ListView.separated(
              itemCount: l.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) => ListTile(
                leading: Icon(l[i].esAdmin ? Icons.admin_panel_settings : Icons.warehouse),
                title: Text(l[i].nombre),
                subtitle: Text('${l[i].email} Â· ${l[i].esAdmin ? 'Administrador' : 'Bodega'}'),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(icon: const Icon(Icons.edit), onPressed: () => _editar(l[i])),
                  if (l[i].id != widget.perfil.id)
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        if (!await confirmar(context, 'Â¿Eliminar a ${l[i].nombre}?')) return;
                        await Api.eliminarUsuario(l[i].id);
                        _recargar();
                      },
                    ),
                ]),
              ),
            );
          },
        ),
      );
}