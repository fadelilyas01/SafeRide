import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../domain/entities/payment_method_entity.dart';
import '../../core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StripeService {
  /// Calls the backend to create a real Stripe PaymentIntent
  Future<Map<String, dynamic>> _createPaymentIntentOnBackend(String rideId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      
      if (token == null) throw Exception('Non authentifié');

      final url = Uri.parse('${AppConstants.apiBaseUrl}/payments/$rideId/intent');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create PaymentIntent on backend: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error / intent creation failed: $e');
    }
  }

  /// Processes the payment flow using Stripe PaymentSheet
  Future<bool> processPaymentSheet(String rideId, double amount) async {
    try {
      // 1. Fetch Payment Intent from Backend
      final intentData = await _createPaymentIntentOnBackend(rideId);
      final clientSecret = intentData['clientSecret'];

      // 2. Initialize the Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'SafeRide',
          style: ThemeMode.system,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Color(0xFF2B3A70),
            ),
          ),
        ),
      );

      // 3. Present the Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      // 4. Confirm Payment on the Backend
      return await _confirmPaymentOnBackend(rideId);

    } on StripeException catch (e) {
      if (kDebugMode) {
        print('Stripe Exception: ${e.error.localizedMessage}');
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Payment Exception: $e');
      }
      return false;
    }
  }

  /// Tells the backend that the PaymentSheet completed successfully
  Future<bool> _confirmPaymentOnBackend(String rideId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      
      if (token == null) return false;

      final url = Uri.parse('${AppConstants.apiBaseUrl}/payments/$rideId/confirm');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to confirm payment on backend: $e');
      }
      return false;
    }
  }

  /// Legacy methods (can be adapted or removed depending on domain logic)
  Future<String> createPaymentIntent(double amount, String currency) async {
    // Replaced by Backend logic
    return 'pi_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<bool> confirmPayment(String paymentIntentId, String paymentMethodId) async {
    // Replaced by Backend logic
    return true;
  }

  Future<PaymentMethodEntity> addPaymentMethod() async {
    await Future.delayed(const Duration(seconds: 1));
    return PaymentMethodEntity(
      id: 'pm_${DateTime.now().millisecondsSinceEpoch}',
      type: 'card',
      last4: '4242',
      brand: 'visa',
      isDefault: true,
    );
  }
}
