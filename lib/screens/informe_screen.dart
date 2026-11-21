import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../services/api.dart';
import '../services/pdf_report.dart';
import '../widgets.dart';

class InformeScreen extends StatefulWidget {
  const InformeScreen({super.key});
  @override
  State<InformeScreen> createState() => _InformeScreenState();
}

class _InformeScreenState extends State<InformeScreen> {
  late Future<List<Row>> _f = Api.resumen();

  @override
  Widget build(BuildContext context) => FutureBuilder<List<Row>>(
        future: _f,
        builder: (c, s) {
          if (!s.hasData) return Center(child: s.hasError ? Text('${s.error}') : const CircularProgressIndicator());
          final r = s.data!;
          if (r.isEmpty) return const Center(child: Text('Sin datos para informar'));
          final maxY = r.fold<double>(1, (p, e) => [p, e['recibido'] as double, e['devuelto'] as double].reduce((a, b) => a > b ? a : b)) * 1.2;
          return ListView(padding: const EdgeInsets.all(16), children: [
            Row(children: [
              const Expanded(child: Text('Recibido vs Devuelto al proveedor', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
              FilledButton.icon(
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Generar PDF'),
                onPressed: () async {
                  try {
                    await generarInforme(r, await Api.movimientos());
                  } catch (e) {
                    if (context.mounted) snack(context, 'Error PDF: $e');
                  }
                },
              ),
            ]),
            const SizedBox(height: 8),
            Row(children: const [
              Icon(Icons.square, color: Colors.blue, size: 14), Text(' Recibido   '),
              Icon(Icons.square, color: Colors.orange, size: 14), Text(' Devuelto'),
            ]),
            const SizedBox(height: 12),
            SizedBox(
              height: 320,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: (r.length * 90.0).clamp(320, 4000),
                  child: BarChart(BarChartData(
                    maxY: maxY,
                    barGroups: [
                      for (var i = 0; i < r.length; i++)
                        BarChartGroupData(x: i, barRods: [
                          BarChartRodData(toY: r[i]['recibido'], color: Colors.blue, width: 16),
                          BarChartRodData(toY: r[i]['devuelto'], color: Colors.orange, width: 16),
                        ]),
                    ],
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 44)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (v, _) {
                            final n = r[v.toInt()]['nombre'] as String;
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(n.length > 12 ? '${n.substring(0, 11)}â€¦' : n, style: const TextStyle(fontSize: 10)),
                            );
                          },
                        ),
                      ),
                    ),
                  )),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Elemento')),
                  DataColumn(label: Text('Recibido'), numeric: true),
                  DataColumn(label: Text('Devuelto'), numeric: true),
                  DataColumn(label: Text('Saldo en obra'), numeric: true),
                ],
                rows: [
                  for (final e in r)
                    DataRow(cells: [
                      DataCell(Text(e['nombre'])),
                      DataCell(Text(fmt(e['recibido']))),
                      DataCell(Text(fmt(e['devuelto']))),
                      DataCell(Text(fmt(e['saldo']))),
                    ]),
                ],
              ),
            ),
          ]);
        },
      );
}