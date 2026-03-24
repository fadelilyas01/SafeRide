import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:saferide/l10n/app_localizations.dart';
import 'injection_container.dart' as di;
import 'presentation/blocs/auth_bloc/auth_bloc.dart';
import 'presentation/blocs/location_bloc/location_bloc.dart';
import 'presentation/blocs/ride_bloc/ride_bloc.dart';
import 'presentation/blocs/chat_bloc/chat_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/utils/app_router.dart';
import 'data/datasources/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialisation de Firebase
    await Firebase.initializeApp();

    // Initialisation de Stripe
    // À REMPLACER PAR VOTRE CLÉ PUBLIQUE STRIPE (pk_test_...)
    Stripe.publishableKey = 'pk_test_123456789';
    await Stripe.instance.applySettings();
  } catch (e) {
    debugPrint('Erreur d\'initialisation Firebase : $e');
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Configuration Firebase Manquante',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Veuillez ajouter le fichier google-services.json dans android/app/ pour pouvoir lancer l\'application.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => main(),
                  child: const Text('RÉESSAYER'),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
    return;
  }
  
  // Initialisation de l'injection de dépendances
  await di.init();
  
  // Initialisation des notifications
  await di.sl<NotificationService>().initialize();
  
  runApp(const SafeRideApp());
}

class SafeRideApp extends StatelessWidget {
  const SafeRideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => di.sl<AuthBloc>()),
        BlocProvider(create: (context) => di.sl<LocationBloc>()),
        BlocProvider(create: (context) => di.sl<RideBloc>()),
        BlocProvider(create: (context) => di.sl<ChatBloc>()),
      ],
      child: MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('fr'),
          Locale('en'),
        ],
      ),
    );
  }
}
