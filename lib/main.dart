import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'screens/user_dashboard_screen.dart';
import 'services/meditation_service.dart';
import 'providers/meditation_provider.dart';
import 'providers/user_profile_provider.dart';
import 'providers/auth_provider.dart';

void main() {
  runApp(const MeditationApp());
}

class MeditationApp extends StatelessWidget {
  const MeditationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MeditationProvider()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Lasèv',
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: 'Roboto',
        ),
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
        routes: {
          '/welcome': (context) => const WelcomeScreen(),
          '/home': (context) => const HomeScreen(),
          '/dashboard': (context) => const UserDashboardScreen(),
        },
      ),
    );
  }
}
