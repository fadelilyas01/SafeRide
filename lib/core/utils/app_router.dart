import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../presentation/blocs/auth_bloc/auth_bloc.dart';
import '../../presentation/blocs/auth_bloc/auth_state.dart';
import '../../presentation/screens/splash_screen.dart';
import '../../presentation/screens/onboarding_screen.dart';
import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/register_screen.dart';
import '../../presentation/screens/kyc_screen.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/ride_planning_screen.dart';
import '../../presentation/screens/active_ride_screen.dart';
import '../../presentation/screens/driver_dashboard_screen.dart';
import '../../presentation/screens/profile_screen.dart';
import '../../presentation/screens/payment_methods_screen.dart';
import '../../presentation/screens/transaction_history_screen.dart';
import '../../presentation/screens/help_support_screen.dart';
import '../../presentation/screens/faq_screen.dart';
import '../../presentation/screens/support_chat_screen.dart';
import '../../presentation/screens/wallet_screen.dart';
import '../../presentation/screens/ai_assistant_screen.dart';
import '../../presentation/screens/safescore_screen.dart';
import '../../core/constants/app_constants.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/kyc',
        builder: (context, state) => const KycScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/payment-methods',
        builder: (context, state) => const PaymentMethodsScreen(),
      ),
      GoRoute(
        path: '/transactions',
        builder: (context, state) => const TransactionHistoryScreen(),
      ),
      GoRoute(
        path: '/wallet',
        builder: (context, state) => const WalletScreen(),
      ),
      GoRoute(
        path: '/help-support',
        builder: (context, state) => const HelpSupportScreen(),
      ),
      GoRoute(
        path: '/faq',
        builder: (context, state) => const FAQScreen(),
      ),
      GoRoute(
        path: '/support-chat',
        builder: (context, state) => const SupportChatScreen(),
      ),
      GoRoute(
        path: '/ai-assistant',
        builder: (context, state) => const AIAssistantScreen(),
      ),
      GoRoute(
        path: '/safescore',
        builder: (context, state) => const SafeScoreScreen(),
      ),
      GoRoute(
        path: '/driver-dashboard',
        builder: (context, state) => const DriverDashboardScreen(),
      ),
      GoRoute(
        path: '/planning',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>?;
          final pickup = extras?['pickup'] as LatLng? ?? const LatLng(0, 0);
          return RidePlanningScreen(pickupLocation: pickup);
        },
      ),
      GoRoute(
        path: '/active-ride/:id',
        builder: (context, state) => ActiveRideScreen(rideId: state.pathParameters['id']!),
      ),
    ],
    redirect: (context, state) {
      final authState = context.read<AuthBloc>().state;
      final bool loggingIn = state.matchedLocation == '/login';
      final bool registering = state.matchedLocation == '/register';
      final bool onSplash = state.matchedLocation == '/splash';
      final bool onOnboarding = state.matchedLocation == '/onboarding';
      final bool onKyc = state.matchedLocation == '/kyc';

      if (onSplash) return null;

      if (authState is Unauthenticated) {
        if (loggingIn || onOnboarding || registering) return null;
        return '/onboarding';
      }

      if (authState is Authenticated) {
        // Redirection vers KYC si c'est un conducteur non vérifié
        if (authState.user.role == UserRole.driver && !authState.user.isVerified) {
          if (onKyc) return null;
          return '/kyc';
        }
        
        // Redirection Dashboard pour les conducteurs
        if (authState.user.role == UserRole.driver && state.matchedLocation == '/home') {
          return '/driver-dashboard';
        }

        if (loggingIn || onSplash || onOnboarding || registering || onKyc) {
          return authState.user.role == UserRole.driver ? '/driver-dashboard' : '/home';
        }
      }

      return null;
    },
  );
}
