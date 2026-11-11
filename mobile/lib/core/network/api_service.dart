import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Service HTTP SafeRide résilient avec Timeouts stricts (8s) et Clés d'Idempotence CSPRNG.
class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3001';
    }
    // Sur Android connecté via USB avec adb reverse tcp:3001 tcp:3001, localhost fonctionne parfaitement.
    return 'http://localhost:3001';
  }

  /// Génère une clé d'idempotence cryptographique unique.
  static String generateIdempotencyKey() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    return values.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Duration timeout = const Duration(seconds: 8),
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await http
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(timeout);

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 400) {
      throw Exception(data['error'] ?? 'Erreur de communication avec le serveur (${response.statusCode})');
    }
    return data;
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool idempotent = true,
    Duration timeout = const Duration(seconds: 8),
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (idempotent) {
      headers['Idempotency-Key'] = generateIdempotencyKey();
    }

    final response = await http
        .post(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(timeout);

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 400) {
      throw Exception(data['error'] ?? 'Échec de la requête (${response.statusCode})');
    }
    return data;
  }

  Future<Map<String, dynamic>> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    bool idempotent = true,
    Duration timeout = const Duration(seconds: 8),
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (idempotent) {
      headers['Idempotency-Key'] = generateIdempotencyKey();
    }

    final response = await http
        .patch(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(timeout);

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 400) {
      throw Exception(data['error'] ?? 'Échec de la mise à jour (${response.statusCode})');
    }
    return data;
  }
}

