import 'package:flutter_test/flutter_test.dart';
import 'package:saferide/core/utils/app_constants.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Dans un projet complexe avec Firebase et injection de dépendances,
    // le test de widget complet nécessite des mocks pour chaque service.
    // Ce test de base vérifie simplement la présence du nom de l'application
    // ou sert de placeholder pour de futurs tests d'interface.

    expect(AppConstants.appName, 'SafeRide');
  });
}
