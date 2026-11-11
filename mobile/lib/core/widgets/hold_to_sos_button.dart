import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_tokens.dart';

/// Bouton SOS de niveau aéronautique avec appui maintenu (1.5s) anti-déclenchement accidentel.
class HoldToSosButton extends StatefulWidget {
  final Future<void> Function() onTrigger;
  final Duration holdDuration;

  const HoldToSosButton({
    super.key,
    required this.onTrigger,
    this.holdDuration = const Duration(milliseconds: 1500),
  });

  @override
  State<HoldToSosButton> createState() => _HoldToSosButtonState();
}

class _HoldToSosButtonState extends State<HoldToSosButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.holdDuration,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _triggerSos();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _triggerSos() async {
    HapticFeedback.heavyImpact();
    setState(() => _isSending = true);
    try {
      await widget.onTrigger();
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
        _controller.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (!_isSending) {
          HapticFeedback.lightImpact();
          _controller.forward();
        }
      },
      onTapUp: (_) {
        if (!_isSending && _controller.status != AnimationStatus.completed) {
          _controller.reverse();
        }
      },
      onTapCancel: () {
        if (!_isSending && _controller.status != AnimationStatus.completed) {
          _controller.reverse();
        }
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final progress = _controller.value;

          return Container(
            height: AppTokens.minTouchTarget,
            decoration: BoxDecoration(
              color: AppTokens.danger,
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              boxShadow: [
                if (progress > 0)
                  BoxShadow(
                    color: AppTokens.danger.withValues(alpha: 0.4 + progress * 0.4),
                    blurRadius: 10 + progress * 10,
                    spreadRadius: progress * 3,
                  ),
              ],
            ),
            child: Stack(
              children: [
                // Barre de progression intérieure
                if (progress > 0)
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTokens.white.withValues(alpha: 0.28),
                        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                      ),
                    ),
                  ),

                // Contenu textuel & icône
                Center(
                  child: _isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: AppTokens.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: AppTokens.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              progress > 0 ? 'MAINTENEZ (${(progress * 100).toInt()}%)' : 'MAINTENIR POUR SOS',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: AppTokens.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
