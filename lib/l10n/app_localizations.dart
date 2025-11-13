import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('hi')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Birthday Calendar'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @addBirthday.
  ///
  /// In en, this message translates to:
  /// **'Add Birthday'**
  String get addBirthday;

  /// No description provided for @contactsImportedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Contacts Imported Successfully'**
  String get contactsImportedSuccessfully;

  /// No description provided for @noContactsFoundMsg.
  ///
  /// In en, this message translates to:
  /// **'There are no contacts on your device'**
  String get noContactsFoundMsg;

  /// No description provided for @alreadyAddedContactsMsg.
  ///
  /// In en, this message translates to:
  /// **'All of your current contacts have already been added'**
  String get alreadyAddedContactsMsg;

  /// No description provided for @unableToMakeCallMsg.
  ///
  /// In en, this message translates to:
  /// **'We are unable to make the call'**
  String get unableToMakeCallMsg;

  /// No description provided for @january.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get january;

  /// No description provided for @february.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get february;

  /// No description provided for @march.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get march;

  /// No description provided for @april.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get april;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @june.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get june;

  /// No description provided for @july.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get july;

  /// No description provided for @august.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get august;

  /// No description provided for @september.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get september;

  /// No description provided for @october.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get october;

  /// No description provided for @november.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get november;

  /// No description provided for @december.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get december;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get ok;

  /// No description provided for @updateSuccessfullyInstalledTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Successfully Installed'**
  String get updateSuccessfullyInstalledTitle;

  /// No description provided for @updateSuccessfullyInstalledDescription.
  ///
  /// In en, this message translates to:
  /// **'Birthday Calendar has been updated successfully! 🎂'**
  String get updateSuccessfullyInstalledDescription;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again?'**
  String get tryAgain;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @updateFailedToInstallTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Failed To Install ❌'**
  String get updateFailedToInstallTitle;

  /// No description provided for @updateFailedToInstallDescription.
  ///
  /// In en, this message translates to:
  /// **'Birthday Calendar has failed to update because: {error}'**
  String updateFailedToInstallDescription(Object error);

  /// No description provided for @userDeniedUpdate.
  ///
  /// In en, this message translates to:
  /// **'User denied update'**
  String get userDeniedUpdate;

  /// No description provided for @appUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'App Update Failed'**
  String get appUpdateFailed;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @importContacts.
  ///
  /// In en, this message translates to:
  /// **'Import Contacts'**
  String get importContacts;

  /// No description provided for @clearNotifications.
  ///
  /// In en, this message translates to:
  /// **'Clear Notifications'**
  String get clearNotifications;

  /// No description provided for @clearNotificationsAlertTitle.
  ///
  /// In en, this message translates to:
  /// **'Are You Sure?'**
  String get clearNotificationsAlertTitle;

  /// No description provided for @clearNotificationsAlertDescription.
  ///
  /// In en, this message translates to:
  /// **'Do you want to remove all notifications?'**
  String get clearNotificationsAlertDescription;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @addPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Add Phone Number'**
  String get addPhoneNumber;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @proceed.
  ///
  /// In en, this message translates to:
  /// **'Proceed'**
  String get proceed;

  /// No description provided for @hintTextForNameInputField.
  ///
  /// In en, this message translates to:
  /// **'Name?'**
  String get hintTextForNameInputField;

  /// No description provided for @notValidName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid name'**
  String get notValidName;

  /// No description provided for @nameAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'A birthday with this name already exists'**
  String get nameAlreadyExists;

  /// No description provided for @birthdaysForDayAndMonth.
  ///
  /// In en, this message translates to:
  /// **'Birthdays for {day} {month}'**
  String birthdaysForDayAndMonth(Object day, Object month);

  /// No description provided for @helpTextChooseBirthdateForImportedContact.
  ///
  /// In en, this message translates to:
  /// **'Choose birth date for {contactName}'**
  String helpTextChooseBirthdateForImportedContact(Object contactName);

  /// No description provided for @fieldLabelTextChooseBirthdateForImportedContact.
  ///
  /// In en, this message translates to:
  /// **'{contactName}\'s birth date'**
  String fieldLabelTextChooseBirthdateForImportedContact(Object contactName);

  /// No description provided for @notificationForBirthdayMessage.
  ///
  /// In en, this message translates to:
  /// **'{contactName} has an upcoming birthday!'**
  String notificationForBirthdayMessage(Object contactName);

  /// No description provided for @addBirthdaysToContactsAlertDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Birthdays To Contacts'**
  String get addBirthdaysToContactsAlertDialogTitle;

  /// No description provided for @addBirthdaysToContactsAlertDialogDescription.
  ///
  /// In en, this message translates to:
  /// **'Would you like to add birth dates for your imported contacts?'**
  String get addBirthdaysToContactsAlertDialogDescription;

  /// No description provided for @peopleWithoutBirthdaysAlertDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'People Without Birthdays'**
  String get peopleWithoutBirthdaysAlertDialogTitle;

  /// No description provided for @notificationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'In order to get notifications for birthdays, you will need to authorize BirthdayCalendar to send you notifications'**
  String get notificationPermissionDenied;

  /// No description provided for @notificationPermissionPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'You will need to turn on the notification permission in the application\'s settings in order to schedule notifications'**
  String get notificationPermissionPermanentlyDenied;

  /// No description provided for @notificationPermissionDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification Permission Request'**
  String get notificationPermissionDialogTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
