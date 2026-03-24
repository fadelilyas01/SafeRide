// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'SafeRide';

  @override
  String get homeWhereTo => 'Où allez-vous ?';

  @override
  String get homeSearchHint => 'Rechercher une destination...';

  @override
  String get homePlanRide => 'Planifier un trajet';

  @override
  String get navHome => 'Accueil';

  @override
  String get navProfile => 'Mon Profil';

  @override
  String get navHistory => 'Historique des trajets';

  @override
  String get navPayment => 'Paiement';

  @override
  String get navSecurity => 'Sécurité';

  @override
  String get navLogout => 'Déconnexion';

  @override
  String get profileSosContacts => 'SOS+ : Contacts d\'Urgence';

  @override
  String get profileSosHint =>
      'Ces contacts seront alertés si vous utilisez le bouton SOS durant un trajet.';

  @override
  String get profileAddContact => 'AJOUTER UN CONTACT';

  @override
  String get profileTitle => 'Mon Profil';

  @override
  String get profileNameLabel => 'Nom Complet';

  @override
  String get profilePhoneLabel => 'Numéro de téléphone';

  @override
  String get profileAddContactTitle => 'Ajouter un contact d\'urgence';

  @override
  String get profileRoleDriver => 'CONDUCTEUR';

  @override
  String get profileRolePassenger => 'PASSAGER';

  @override
  String get commonCancel => 'ANNULER';

  @override
  String get commonAdd => 'AJOUTER';

  @override
  String get sosEmergency => 'URGENCE SOS';

  @override
  String get sosAlertSent =>
      'ALERTE SOS ENVOYÉE ! Les secours et vos contacts ont été prévenus.';

  @override
  String get sosConfirmText =>
      'Une alerte immédiate sera envoyée à nos services de sécurité.';

  @override
  String get sosContactsAlertText =>
      'Les contacts suivants recevront également votre position en temps réel :';

  @override
  String get sosNoContactsText =>
      'Note : Vous n\'avez pas configuré de contacts d\'urgence dans votre profil.';

  @override
  String get sosErrorButton => 'Erreur';

  @override
  String get sosActivateButton => 'ACTIVER SOS';
}
