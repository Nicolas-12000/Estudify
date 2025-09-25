import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/di/injection_container.dart' as di;
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/rooms/rooms_bloc.dart';
import 'presentation/blocs/reservations/reservations_bloc.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/register_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/reservations/reservations_screen.dart';
import 'presentation/screens/reservations/reservation_form_screen.dart';
import 'presentation/screens/profile/profile_screen.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env (if exists) but don't fail if it's absent. Priority order:
  // 1) --dart-define values
  // 2) .env values
  // 3) fall back to placeholder
  await dotenv.load(fileName: '.env', mergeWith: {});

  final supabaseUrl =
      const String.fromEnvironment('SUPABASE_URL', defaultValue: '').isNotEmpty
          ? const String.fromEnvironment('SUPABASE_URL')
          : (dotenv.env['SUPABASE_URL'] ?? '');

  final supabaseAnonKey =
      const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '')
              .isNotEmpty
          ? const String.fromEnvironment('SUPABASE_ANON_KEY')
          : (dotenv.env['SUPABASE_ANON_KEY'] ?? '');

  final useSupabase = supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  if (useSupabase) {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

    // Initialize dependency injection
    await di.init();

    runApp(const EstudifyApp());
  } else {
    runApp(const MissingSupabaseConfigApp());
  }
}

class MissingSupabaseConfigApp extends StatelessWidget {
  const MissingSupabaseConfigApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Estudify - Config required',
      home: Scaffold(
        appBar: AppBar(title: const Text('Falta configuración')),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'No has configurado Supabase en esta app.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text('Sigue estos pasos:'),
              SizedBox(height: 8),
              Text(
                  '1) Crea un archivo .env con SUPABASE_URL y SUPABASE_ANON_KEY o define las variables de entorno.'),
              Text(
                  '2) Localmente puedes pasar las variables al ejecutar Flutter:'),
              Text(
                  '   flutter run --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_anon_key'),
              SizedBox(height: 8),
              Text(
                  '3) Alternativamente, instala `flutter_dotenv` y carga las variables en main().'),
              SizedBox(height: 12),
              Text(
                  'Sin estas credenciales la app no puede comunicarse con Supabase y verás errores como:'),
              Text(
                  "AuthFailure(Exception: Error inesperado: Invalid argument(s): No host specified in URI YOUR_SUPABASE_URL/...)")
            ],
          ),
        ),
      ),
    );
  }
}

class EstudifyApp extends StatelessWidget {
  const EstudifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
        BlocProvider(create: (_) => di.sl<RoomsBloc>()),
        BlocProvider(create: (_) => di.sl<ReservationsBloc>()),
      ],
      child: MaterialApp(
        title: 'Estudify',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/reservations': (context) => const ReservationsScreen(),
          '/reservation': (context) => const ReservationFormScreen(),
          '/profile': (context) => const ProfileScreen(),
        },
      ),
    );
  }
}
