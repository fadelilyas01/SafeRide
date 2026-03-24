class AppConstants {
  static const String appName = 'SafeRide';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String ridesCollection = 'rides';
  static const String driversCollection = 'drivers';
  
  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String tokenKey = 'user_token';
  static const String userRoleKey = 'user_role';
  
  // Backend Settings
  static const String apiBaseUrl = 'http://10.0.2.2:3000'; // Change to real domain later

  // Map settings
  static const double defaultZoom = 15.0;

  // Localization & Pricing
  static const String currency = '\$';
  static const String currencyCode = 'CAD';
  static const double tpsRate = 0.05; // 5%
  static const double tvqRate = 0.09975; // 9.975%

  // API Keys (À REMPLIR PAR L'UTILISATEUR)
  static const String googleMapsApiKey = 'VOTRE_CLE_API_GOOGLE_MAPS';
}

enum UserRole { passenger, driver }
