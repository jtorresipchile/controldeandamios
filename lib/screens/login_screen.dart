import 'package:flutter/material.dart';
import '../services/api.dart';
import '../widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _u = TextEditingController(), _p = TextEditingController();
  bool _cargando = false;
  String? _error;

  Future<void> _entrar() async {
    setState(() { _cargando = true; _error = null; });
    try {
      await sb.auth.signInWithPassword(email: _u.text.trim(), password: _p.text);
    } catch (e) {
      setState(() => _error = 'Usuario o contraseÃ±a incorrectos');
    }
    if (mounted) setState(() => _cargando = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        bottomNavigationBar: const AppFooter(),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.construction, size: 56),
                const SizedBox(height: 8),
                const Text('Control de Andamios', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const Text('SEPCO  Â·  Integral / Soinsa'),
                const SizedBox(height: 24),
                TextField(controller: _u, decoration: const InputDecoration(labelText: 'Usuario (correo)', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: _p, obscureText: true, onSubmitted: (_) => _entrar(),
                    decoration: const InputDecoration(labelText: 'ContraseÃ±a', border: OutlineInputBorder())),
                if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: const TextStyle(color: Colors.red))),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, child: FilledButton(onPressed: _cargando ? null : _entrar, child: Text(_cargando ? 'Ingresando...' : 'Ingresar'))),
              ]),
            ),
          ),
        ),
      );
}