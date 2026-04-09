import 'package:flutter/material.dart';

class Responsive {
  /// Retourne `true` si c'est un téléphone
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  /// Retourne `true` si c'est une tablette
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;

  /// Enveloppe le contenu pour qu'il ne s'étire pas trop sur une tablette.
  static Widget bounded({required Widget child, double maxWidth = 600}) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
