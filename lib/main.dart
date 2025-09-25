import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  // Initialize Supabase (replace with your real values or load from env)
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  // Initialize dependency injection
  await di.init();

  runApp(const EstudifyApp());
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
