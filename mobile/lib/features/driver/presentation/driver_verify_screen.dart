import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saferide_mobile/core/network/api_service.dart';
import 'package:saferide_mobile/core/theme/app_tokens.dart';
import 'package:saferide_mobile/core/widgets/pin_pad_widget.dart';
import 'package:saferide_mobile/core/widgets/route_timeline_widget.dart';

class DriverVerifyScreen extends StatefulWidget {
  final Map<String, dynamic> reservation;
  final String driverId;
  final VoidCallback onVerificationSuccess;

  const DriverVerifyScreen({
    super.key,
    required this.reservation,
    required this.driverId,
    required this.onVerificationSuccess,
  });

  @override
  State<DriverVerifyScreen> createState() => _DriverVerifyScreenState();
}

class _DriverVerifyScreenState extends State<DriverVerifyScreen> {
  String _pin = '';
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSuccess = false;

  Future<void> _verifyPin() async {
    if (_pin.length != 4 || _isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ApiService.instance.post(
        '/api/reservations/verify',
        body: {
          'reservationId': widget.reservation['id'],
          'pin': _pin,
          'driverId': widget.driverId,
        },
      );

      HapticFeedback.mediumImpact();
      setState(() => _isSuccess = true);

      await Future.delayed(const Duration(milliseconds: 900));
      if (mounted) {
        Navigator.of(context).pop();
        widget.onVerificationSuccess();
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
      setState(() {
        _pin = '';
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final passengerName = widget.reservation['passenger']?['name'] ?? 'Passager SafeRide';
    final origin = widget.reservation['ride']?['originLabel'] ?? 'Paris - Gare de Lyon';
    final destination = widget.reservation['ride']?['destinationLabel'] ?? 'Campus de Versailles';

    return Scaffold(
      backgroundColor: AppTokens.background,
      appBar: AppBar(
        backgroundColor: AppTokens.background,
        elevation: 0,
        title: const Text(
          'Validation Passager',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppTokens.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTokens.textSecondary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTokens.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Fiche Itinéraire
              Container(
                padding: const EdgeInsets.all(AppTokens.spacingMd),
                decoration: BoxDecoration(
                  color: AppTokens.surfaceInset,
                  borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                  border: Border.all(color: AppTokens.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prise en charge de $passengerName',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppTokens.spacingSm),
                    RouteTimelineWidget(
                      originLabel: origin,
                      destinationLabel: destination,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTokens.spacingXl),

              const Text(
                'Saisissez le code PIN à 4 chiffres communiqué oralement par le passager :',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppTokens.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppTokens.spacingLg),

              // Pavé tactile PIN
              PinPadWidget(
                pin: _pin,
                disabled: _isLoading || _isSuccess,
                onDigitPressed: (digit) {
                  if (_pin.length < 4) {
                    setState(() => _pin += digit);
                  }
                },
                onDeletePressed: () {
                  if (_pin.isNotEmpty) {
                    setState(() => _pin = _pin.substring(0, _pin.length - 1));
                  }
                },
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: AppTokens.spacingMd),
                Container(
                  padding: const EdgeInsets.all(AppTokens.spacingMd),
                  decoration: BoxDecoration(
                    color: AppTokens.dangerMuted,
                    borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                    border: Border.all(color: AppTokens.danger),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: AppTokens.danger, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],

              if (_isSuccess) ...[
                const SizedBox(height: AppTokens.spacingMd),
                Container(
                  padding: const EdgeInsets.all(AppTokens.spacingMd),
                  decoration: BoxDecoration(
                    color: AppTokens.successMuted,
                    borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                    border: Border.all(color: AppTokens.success),
                  ),
                  child: const Text(
                    'Code PIN vérifié en temps constant. Trajet activé !',
                    style: TextStyle(
                      color: AppTokens.success,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],

              const SizedBox(height: AppTokens.spacingXl),

              ElevatedButton(
                onPressed: _pin.length == 4 && !_isLoading && !_isSuccess
                    ? _verifyPin
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTokens.primary,
                  foregroundColor: AppTokens.white,
                  minimumSize: const Size.fromHeight(AppTokens.minTouchTarget),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppTokens.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Valider et Démarrer le Trajet',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

