import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        color: Colors.black12,
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Wrap(
          alignment: WrapAlignment.center,
          children: [
            const Text('Desarrollado por ', style: TextStyle(fontSize: 12)),
            InkWell(
              onTap: () => launchUrl(Uri.parse('https://www.civtek.cl/'),
                  mode: LaunchMode.externalApplication),
              child: const Text('https://www.civtek.cl/',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      decoration: TextDecoration.underline)),
            ),
            const Text(' , Jose Torres 2026', style: TextStyle(fontSize: 12)),
          ],
        ),
      );
}

void snack(BuildContext c, String m) =>
    ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(m)));

Future<bool> confirmar(BuildContext c, String msg) async =>
    await showDialog<bool>(
        context: c,
        builder: (_) => AlertDialog(
              title: const Text('Confirmar'),
              content: Text(msg),
              actions: [
                TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')),
                FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Eliminar')),
              ],
            )) ??
    false;