import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api.dart';
import '../services/pdf_report.dart' show fmt;
import '../widgets.dart';

class MovimientosScreen extends StatefulWidget {
  final Perfil perfil;
  const MovimientosScreen({super.key, required this.perfil});
  @override
  State<MovimientosScreen> createState() => _MovimientosScreenState();
}

class _MovimientosScreenState extends State<MovimientosScreen> {
  late Future<List<Row>> _f = Api.movimientos();
  void _recargar() => setState(() => _f = Api.movimientos());

  Future<void> _nuevo() async {
    final elems = await Api.elementos();
    if (elems.isEmpty) {
      if (mounted) snack(context, 'Primero crea elementos (pestaÃ±a Elementos)');
      return;
    }
    final guia = TextEditingController(), cant = TextEditingController(), obs = TextEditingController();
    String tipo = 'recepcion';
    int elem = elems.first['id'];
    DateTime fecha = DateTime.now();
    if (!mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, set) => AlertDialog(
          title: const Text('Nueva guÃ­a de despacho'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: guia, decoration: const InputDecoration(labelText: 'NÂ° de guÃ­a')),
              DropdownButtonFormField<String>(
                value: tipo,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: const [
                  DropdownMenuItem(value: 'recepcion', child: Text('RecepciÃ³n (Soinsa â†’ SEPCO)')),
                  DropdownMenuItem(value: 'devolucion', child: Text('DevoluciÃ³n (SEPCO â†’ Soinsa)')),
                ],
                onChanged: (v) => set(() => tipo = v!),
              ),
              DropdownButtonFormField<int>(
                value: elem,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Elemento'),
                items: [for (final e in elems) DropdownMenuItem<int>(value: e['id'], child: Text(e['nombre']))],
                onChanged: (v) => set(() => elem = v!),
              ),
              TextField(controller: cant, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Cantidad')),
              TextField(controller: obs, decoration: const InputDecoration(labelText: 'ObservaciÃ³n')),
              const SizedBox(height: 8),
              TextButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(DateFormat('dd-MM-yyyy').format(fecha)),
                onPressed: () async {
                  final d = await showDatePicker(context: c, initialDate: fecha, firstDate: DateTime(2020), lastDate: DateTime(2100));
                  if (d != null) set(() => fecha = d);
                },
              ),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')),
            FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Guardar')),
          ],
        ),
      ),
    );
    final q = double.tryParse(cant.text.replaceAll(',', '.'));
    if (ok != true) return;
    if (guia.text.trim().isEmpty || q == null || q <= 0) {
      if (mounted) snack(context, 'GuÃ­a y cantidad vÃ¡lidas son obligatorias');
      return;
    }
    try {
      await Api.crearMovimiento({
        'guia': guia.text.trim(),
        'tipo': tipo,
        'elemento_id': elem,
        'cantidad': q,
        'fecha': DateFormat('yyyy-MM-dd').format(fecha),
        'observacion': obs.text.trim(),
      });
      _recargar();
    } catch (e) {
      if (mounted) snack(context, 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        floatingActionButton: FloatingActionButton.extended(onPressed: _nuevo, icon: const Icon(Icons.add), label: const Text('GuÃ­a')),
        body: FutureBuilder<List<Row>>(
          future: _f,
          builder: (c, s) {
            if (!s.hasData) return Center(child: s.hasError ? Text('${s.error}') : const CircularProgressIndicator());
            final l = s.data!;
            if (l.isEmpty) return const Center(child: Text('AÃºn no hay guÃ­as ingresadas'));
            return RefreshIndicator(
              onRefresh: () async => _recargar(),
              child: ListView.separated(
                itemCount: l.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final m = l[i];
                  final rec = m['tipo'] == 'recepcion';
                  return ListTile(
                    leading: Icon(rec ? Icons.south_west : Icons.north_east, color: rec ? Colors.blue : Colors.orange),
                    title: Text('${m['elementos']['nombre']}  Â·  ${fmt(m['cantidad'])} ${m['elementos']['unidad']}'),
                    subtitle: Text('GuÃ­a ${m['guia']} Â· ${rec ? 'RecepciÃ³n' : 'DevoluciÃ³n'} Â· ${m['fecha']}'
                        '${(m['observacion'] ?? '').toString().isEmpty ? '' : '\n${m['observacion']}'}'),
                    trailing: widget.perfil.esAdmin
                        ? IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              if (!await confirmar(context, 'Â¿Eliminar este registro de la guÃ­a ${m['guia']}?')) return;
                              await Api.borrarMovimiento(m['id']);
                              _recargar();
                            })
                        : null,
                  );
                },
              ),
            );
          },
        ),
      );
}