import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_tokens.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/dashboard/presentation/main_dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTokens.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const SafeRideApp());
}

class SafeRideApp extends StatefulWidget {
  const SafeRideApp({super.key});

  @override
  State<SafeRideApp> createState() => _SafeRideAppState();
}

class _SafeRideAppState extends State<SafeRideApp> {
  Map<String, dynamic>? _currentUser;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeRide',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppTokens.background,
        colorScheme: const ColorScheme.dark(
          primary: AppTokens.primary,
          surface: AppTokens.surface,
          error: AppTokens.danger,
        ),
      ),
      home: _currentUser == null
          ? LoginScreen(
              onLoginSuccess: (user) {
                setState(() => _currentUser = user);
              },
            )
          : MainDashboardScreen(
              user: _currentUser!,
              onLogout: () {
                setState(() => _currentUser = null);
              },
            ),
    );
  }
}
