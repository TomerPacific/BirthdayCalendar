// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Geburtstagskalender';

  @override
  String get settings => 'Einstellungen';

  @override
  String get addBirthday => 'Geburtstag hinzufügen';

  @override
  String get contactsImportedSuccessfully => 'Kontakte erfolgreich importiert';

  @override
  String get noContactsFoundMsg => 'Es gibt keine Kontakte auf Ihrem Gerät';

  @override
  String get alreadyAddedContactsMsg =>
      'Alle aktuellen Kontakte wurden bereits hinzugefügt';

  @override
  String get unableToMakeCallMsg => 'Wir können den Anruf nicht tätigen';

  @override
  String get january => 'Januar';

  @override
  String get february => 'Februar';

  @override
  String get march => 'März';

  @override
  String get april => 'April';

  @override
  String get may => 'Mai';

  @override
  String get june => 'Juni';

  @override
  String get july => 'Juli';

  @override
  String get august => 'August';

  @override
  String get september => 'September';

  @override
  String get october => 'Oktober';

  @override
  String get november => 'November';

  @override
  String get december => 'Dezember';

  @override
  String get ok => 'Ok';

  @override
  String get updateSuccessfullyInstalledTitle =>
      'Update erfolgreich installiert';

  @override
  String get updateSuccessfullyInstalledDescription =>
      'Geburtstagskalender wurde erfolgreich aktualisiert! 🎂';

  @override
  String get tryAgain => 'Erneut versuchen?';

  @override
  String get dismiss => 'Schließen';

  @override
  String get updateFailedToInstallTitle =>
      'Update konnte nicht installiert werden ❌';

  @override
  String updateFailedToInstallDescription(Object error) {
    return 'Geburtstagskalender konnte nicht aktualisiert werden, weil: $error';
  }

  @override
  String get userDeniedUpdate => 'Benutzer hat das Update abgelehnt';

  @override
  String get appUpdateFailed => 'App-Update fehlgeschlagen';

  @override
  String get darkMode => 'Dunkelmodus';

  @override
  String get importContacts => 'Kontakte importieren';

  @override
  String get clearNotifications => 'Benachrichtigungen löschen';

  @override
  String get clearNotificationsAlertTitle => 'Sind Sie sicher?';

  @override
  String get clearNotificationsAlertDescription =>
      'Möchten Sie alle Benachrichtigungen entfernen?';

  @override
  String get no => 'Nein';

  @override
  String get yes => 'Ja';

  @override
  String get addPhoneNumber => 'Telefonnummer hinzufügen';

  @override
  String get add => 'Hinzufügen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get back => 'Zurück';

  @override
  String get proceed => 'Fortfahren';

  @override
  String get hintTextForNameInputField => 'Name?';

  @override
  String get notValidName => 'Bitte geben Sie einen gültigen Namen ein';

  @override
  String get nameAlreadyExists =>
      'Ein Geburtstag mit diesem Namen existiert bereits';

  @override
  String birthdaysForDayAndMonth(Object day, Object month) {
    return 'Geburtstage am $day. $month';
  }

  @override
  String helpTextChooseBirthdateForImportedContact(Object contactName) {
    return 'Wählen Sie das Geburtsdatum für $contactName';
  }

  @override
  String fieldLabelTextChooseBirthdateForImportedContact(Object contactName) {
    return 'Geburtsdatum von $contactName';
  }

  @override
  String notificationForBirthdayMessage(Object contactName) {
    return '$contactName hat bald Geburtstag!';
  }

  @override
  String get addBirthdaysToContactsAlertDialogTitle =>
      'Geburtstage zu Kontakten hinzufügen';

  @override
  String get addBirthdaysToContactsAlertDialogDescription =>
      'Möchten Sie Geburtsdaten für Ihre importierten Kontakte hinzufügen?';

  @override
  String get peopleWithoutBirthdaysAlertDialogTitle =>
      'Personen ohne Geburtstage';

  @override
  String get notificationPermissionDenied =>
      'Um Benachrichtigungen zu Geburtstagen zu erhalten, müssen Sie BirthdayCalendar die Berechtigung erteilen, Ihnen Benachrichtigungen zu senden';

  @override
  String get notificationPermissionPermanentlyDenied =>
      'Sie müssen die Benachrichtigungsberechtigung in den App-Einstellungen aktivieren, um Benachrichtigungen planen zu können.';

  @override
  String get openSettings => 'Einstellungen öffnen';

  @override
  String get contactsPermissionRationale =>
      'Birthday Calendar benötigt Zugriff auf Ihre Kontakte, um Geburtstage zu importieren.';

  @override
  String get notificationPermissionRationale =>
      'Um Benachrichtigungen zu Geburtstagen zu erhalten, müssen Sie BirthdayCalendar die Berechtigung erteilen, Ihnen Benachrichtigungen zu senden.';
}
