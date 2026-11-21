import 'package:supabase_flutter/supabase_flutter.dart';
import '../config.dart';

final sb = Supabase.instance.client;

class Perfil {
  final String id, email, nombre, rol;
  Perfil(this.id, this.email, this.nombre, this.rol);
  bool get esAdmin => rol == 'admin';
  factory Perfil.fromMap(Map<String, dynamic> m) =>
      Perfil(m['id'], m['email'] ?? '', m['nombre'] ?? '', m['rol']);
}

typedef Row = Map<String, dynamic>;

class Api {
  static Future<Perfil?> perfilActual() async {
    final u = sb.auth.currentUser;
    if (u == null) return null;
    final r = await sb.from('perfiles').select().eq('id', u.id).maybeSingle();
    return r == null ? null : Perfil.fromMap(r);
  }

  // ---- Elementos
  static Future<List<Row>> elementos() async =>
      List<Row>.from(await sb.from('elementos').select().order('nombre'));
  static Future<void> guardarElemento(int? id, String nombre, String unidad) async {
    final d = {'nombre': nombre, 'unidad': unidad};
    if (id == null) {
      await sb.from('elementos').insert(d);
    } else {
      await sb.from('elementos').update(d).eq('id', id);
    }
  }

  static Future<void> borrarElemento(int id) =>
      sb.from('elementos').delete().eq('id', id);

  // ---- Movimientos (guÃ­as)
  static Future<List<Row>> movimientos() async => List<Row>.from(await sb
      .from('movimientos')
      .select('*, elementos(nombre, unidad)')
      .order('fecha', ascending: false)
      .order('id', ascending: false));
  static Future<void> crearMovimiento(Row d) => sb.from('movimientos').insert(d);
  static Future<void> borrarMovimiento(int id) =>
      sb.from('movimientos').delete().eq('id', id);

  /// Resumen por elemento: recibido, devuelto, saldo
  static Future<List<Row>> resumen() async {
    final movs = await movimientos();
    final Map<String, Row> acc = {};
    for (final m in movs) {
      final e = m['elementos'] as Map;
      final k = e['nombre'] as String;
      acc.putIfAbsent(k, () => {'nombre': k, 'unidad': e['unidad'], 'recibido': 0.0, 'devuelto': 0.0});
      final c = (m['cantidad'] as num).toDouble();
      final campo = m['tipo'] == 'recepcion' ? 'recibido' : 'devuelto';
      acc[k]![campo] = (acc[k]![campo] as double) + c;
    }
    final l = acc.values.toList()
      ..sort((a, b) => (a['nombre'] as String).compareTo(b['nombre'] as String));
    for (final r in l) {
      r['saldo'] = (r['recibido'] as double) - (r['devuelto'] as double);
    }
    return l;
  }

  // ---- Usuarios (solo admin)
  static Future<List<Perfil>> usuarios() async =>
      (await sb.from('perfiles').select().order('nombre'))
          .map<Perfil>((m) => Perfil.fromMap(m))
          .toList();

  /// Crea el usuario con un cliente temporal para no cerrar la sesiÃ³n del admin.
  static Future<void> crearUsuario(
      String email, String pass, String nombre, String rol) async {
    final tmp = SupabaseClient(kSupabaseUrl, kSupabaseAnonKey,
        authOptions: const AuthClientOptions(autoRefreshToken: false));
    try {
      final res = await tmp.auth.signUp(email: email, password: pass);
      final id = res.user?.id;
      if (id == null) throw 'No se pudo crear el usuario';
      await sb.from('perfiles').insert(
          {'id': id, 'email': email, 'nombre': nombre, 'rol': rol});
    } finally {
      await tmp.dispose();
    }
  }

  static Future<void> actualizarUsuario(String id, String nombre, String rol) =>
      sb.from('perfiles').update({'nombre': nombre, 'rol': rol}).eq('id', id);

  /// Elimina el perfil: el usuario ya no puede entrar a la app.
  static Future<void> eliminarUsuario(String id) =>
      sb.from('perfiles').delete().eq('id', id);
}