import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'api.dart';

String fmt(num n) => NumberFormat('#,##0.##', 'es_CL').format(n);

Future<void> generarInforme(List<Row> resumen, List<Row> movs) async {
  final doc = pw.Document();
  final fecha = DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now());
  final maxV = resumen.fold<double>(
      1, (p, r) => [p, r['recibido'] as double, r['devuelto'] as double].reduce((a, b) => a > b ? a : b));

  pw.Widget bar(double v, PdfColor c) => pw.Container(
      height: 8, width: 200 * (v / maxV), color: c);

  doc.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(32),
    header: (_) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Text('Informe de Recepciones y Devoluciones',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
      pw.Text('SEPCO  |  Proveedor: Integral / Soinsa  |  Generado: $fecha'),
      pw.Divider(),
    ]),
    footer: (c) => pw.Column(children: [
      pw.Divider(),
      pw.Text('Desarrollado por https://www.civtek.cl/ , Jose Torres 2026   -   PÃ¡g. ${c.pageNumber}/${c.pagesCount}',
          style: const pw.TextStyle(fontSize: 8)),
    ]),
    build: (_) => [
      pw.Text('Resumen por elemento', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 6),
      pw.TableHelper.fromTextArray(
        headers: ['Elemento', 'Unidad', 'Recibido', 'Devuelto', 'Saldo en obra'],
        data: resumen
            .map((r) => [r['nombre'], r['unidad'], fmt(r['recibido']), fmt(r['devuelto']), fmt(r['saldo'])])
            .toList(),
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
        cellAlignment: pw.Alignment.centerLeft,
      ),
      pw.SizedBox(height: 16),
      pw.Text('GrÃ¡fico (azul = recibido, naranja = devuelto)',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 6),
      ...resumen.map((r) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 6),
            child: pw.Row(children: [
              pw.SizedBox(width: 140, child: pw.Text(r['nombre'], style: const pw.TextStyle(fontSize: 9))),
              pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                bar(r['recibido'], PdfColors.blue700),
                pw.SizedBox(height: 2),
                bar(r['devuelto'], PdfColors.orange700),
              ]),
            ]),
          )),
      pw.SizedBox(height: 16),
      pw.Text('Detalle de guÃ­as de despacho',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 6),
      pw.TableHelper.fromTextArray(
        headers: ['Fecha', 'GuÃ­a', 'Tipo', 'Elemento', 'Cant.', 'Obs.'],
        data: movs
            .map((m) => [
                  m['fecha'],
                  m['guia'],
                  m['tipo'] == 'recepcion' ? 'RecepciÃ³n' : 'DevoluciÃ³n',
                  m['elementos']['nombre'],
                  fmt(m['cantidad']),
                  m['observacion'] ?? '',
                ])
            .toList(),
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
        cellStyle: const pw.TextStyle(fontSize: 8),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      ),
    ],
  ));

  await Printing.sharePdf(
      bytes: await doc.save(), filename: 'informe_andamios_sepco.pdf');
}