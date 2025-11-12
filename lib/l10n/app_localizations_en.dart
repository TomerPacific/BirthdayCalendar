// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Birthday Calendar';

  @override
  String get settings => 'Settings';

  @override
  String get addBirthday => 'Add Birthday';

  @override
  String get contactsImportedSuccessfully => 'Contacts Imported Successfully';

  @override
  String get noContactsFoundMsg => 'There are no contacts on your device';

  @override
  String get alreadyAddedContactsMsg =>
      'All of your current contacts have already been added';

  @override
  String get unableToMakeCallMsg => 'We are unable to make the call';

  @override
  String get january => 'January';

  @override
  String get february => 'February';

  @override
  String get march => 'March';

  @override
  String get april => 'April';

  @override
  String get may => 'May';

  @override
  String get june => 'June';

  @override
  String get july => 'July';

  @override
  String get august => 'August';

  @override
  String get september => 'September';

  @override
  String get october => 'October';

  @override
  String get november => 'November';

  @override
  String get december => 'December';

  @override
  String get ok => 'Ok';

  @override
  String get updateSuccessfullyInstalledTitle =>
      'Update Successfully Installed';

  @override
  String get updateSuccessfullyInstalledDescription =>
      'Birthday Calendar has been updated successfully! 🎂';

  @override
  String get tryAgain => 'Try Again?';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get updateFailedToInstallTitle => 'Update Failed To Install ❌';

  @override
  String updateFailedToInstallDescription(Object error) {
    return 'Birthday Calendar has failed to update because: $error';
  }

  @override
  String get userDeniedUpdate => 'User denied update';

  @override
  String get appUpdateFailed => 'App Update Failed';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get importContacts => 'Import Contacts';

  @override
  String get clearNotifications => 'Clear Notifications';

  @override
  String get clearNotificationsAlertTitle => 'Are You Sure?';

  @override
  String get clearNotificationsAlertDescription =>
      'Do you want to remove all notifications?';

  @override
  String get no => 'No';

  @override
  String get yes => 'Yes';

  @override
  String get addPhoneNumber => 'Add Phone Number';

  @override
  String get add => 'Add';

  @override
  String get cancel => 'Cancel';

  @override
  String get back => 'Back';

  @override
  String get proceed => 'Proceed';

  @override
  String get hintTextForNameInputField => 'Name?';

  @override
  String get notValidName => 'Please enter a valid name';

  @override
  String get nameAlreadyExists => 'A birthday with this name already exists';

  @override
  String birthdaysForDayAndMonth(Object day, Object month) {
    return 'Birthdays for $day $month';
  }

  @override
  String helpTextChooseBirthdateForImportedContact(Object contactName) {
    return 'Choose birth date for $contactName';
  }

  @override
  String fieldLabelTextChooseBirthdateForImportedContact(Object contactName) {
    return '$contactName\'s birth date';
  }

  @override
  String notificationForBirthdayMessage(Object contactName) {
    return '$contactName has an upcoming birthday!';
  }

  @override
  String get addBirthdaysToContactsAlertDialogTitle =>
      'Add Birthdays To Contacts';

  @override
  String get addBirthdaysToContactsAlertDialogDescription =>
      'Would you like to add birth dates for your imported contacts?';

  @override
  String get peopleWithoutBirthdaysAlertDialogTitle =>
      'People Without Birthdays';

  @override
  String get notificationPermissionDenied =>
      'In order to use this application, you will need to authorize it to send you notifications';

  @override
  String get notificationPermissionPermanentlyDenied =>
      'You will need to turn on the notification permission in the application\'s settings';
}
