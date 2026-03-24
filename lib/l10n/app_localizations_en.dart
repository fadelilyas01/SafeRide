// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SafeRide';

  @override
  String get homeWhereTo => 'Where to?';

  @override
  String get homeSearchHint => 'Search destination...';

  @override
  String get homePlanRide => 'Plan a ride';

  @override
  String get navHome => 'Home';

  @override
  String get navProfile => 'My Profile';

  @override
  String get navHistory => 'Ride History';

  @override
  String get navPayment => 'Payment';

  @override
  String get navSecurity => 'Security';

  @override
  String get navLogout => 'Logout';

  @override
  String get profileSosContacts => 'SOS+: Emergency Contacts';

  @override
  String get profileSosHint =>
      'These contacts will be alerted if you use the SOS button during a ride.';

  @override
  String get profileAddContact => 'ADD A CONTACT';

  @override
  String get profileTitle => 'My Profile';

  @override
  String get profileNameLabel => 'Full Name';

  @override
  String get profilePhoneLabel => 'Phone Number';

  @override
  String get profileAddContactTitle => 'Add Emergency Contact';

  @override
  String get profileRoleDriver => 'DRIVER';

  @override
  String get profileRolePassenger => 'PASSENGER';

  @override
  String get commonCancel => 'CANCEL';

  @override
  String get commonAdd => 'ADD';

  @override
  String get sosEmergency => 'SOS EMERGENCY';

  @override
  String get sosAlertSent =>
      'SOS ALERT SENT! Emergency services and your contacts have been notified.';

  @override
  String get sosConfirmText =>
      'An immediate alert will be sent to our security services.';

  @override
  String get sosContactsAlertText =>
      'The following contacts will also receive your real-time position:';

  @override
  String get sosNoContactsText =>
      'Note: You haven\'t configured any emergency contacts in your profile.';

  @override
  String get sosErrorButton => 'Error';

  @override
  String get sosActivateButton => 'ACTIVATE SOS';
}
