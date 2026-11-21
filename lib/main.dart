import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config.dart';
import 'services/api.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: kSupabaseUrl, anonKey: kSupabaseAnonKey);
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Control Andamios SEPCO',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            colorSchemeSeed: const Color(0xFF1F5FA6), useMaterial3: true),
        home: StreamBuilder<AuthState>(
          stream: sb.auth.onAuthStateChange,
          builder: (_, __) => sb.auth.currentSession == null
              ? const LoginScreen()
              : const HomeScreen(),
        ),
      );
}