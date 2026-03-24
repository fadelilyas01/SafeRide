import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Demander les permissions pour iOS et Android 13+
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('User granted permission');
      }
      
      // Récupérer le token pour l'envoi ciblé
      String? token = await _fcm.getToken();
      if (kDebugMode) {
        print('FCM Token: $token');
      }

      // Gérer les messages quand l'app est au premier plan
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('Got a message whilst in the foreground!');
          print('Message data: ${message.data}');
        }
        
        if (message.notification != null) {
          if (kDebugMode) {
            print('Message also contained a notification: ${message.notification}');
          }
        }
      });

      // Gérer les messages quand l'app est ouverte via une notification
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('A new onMessageOpenedApp event was published!');
        }
      });
    } else {
      if (kDebugMode) {
        print('User declined or has not accepted permission');
      }
    }
  }

  /// Simulation locale d'une notification (pour démonstration)
  void simulateNotification(String title, String body) {
    if (kDebugMode) {
      print('--- SIMULATION NOTIFICATION ---');
      print('Titre: $title');
      print('Message: $body');
      print('-------------------------------');
    }
  }
}
