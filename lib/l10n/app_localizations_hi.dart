// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'जन्मदिन कैलेंडर';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get addBirthday => 'जन्मदिन जोड़ें';

  @override
  String get contactsImportedSuccessfully => 'संपर्क सफलतापूर्वक आयात किए गए';

  @override
  String get noContactsFoundMsg => 'आपके डिवाइस पर कोई संपर्क नहीं मिला';

  @override
  String get alreadyAddedContactsMsg =>
      'आपके सभी वर्तमान संपर्क पहले ही जोड़े जा चुके हैं';

  @override
  String get unableToMakeCallMsg => 'हम कॉल करने में असमर्थ हैं';

  @override
  String get january => 'जनवरी';

  @override
  String get february => 'फ़रवरी';

  @override
  String get march => 'मार्च';

  @override
  String get april => 'अप्रैल';

  @override
  String get may => 'मई';

  @override
  String get june => 'जून';

  @override
  String get july => 'जुलाई';

  @override
  String get august => 'अगस्त';

  @override
  String get september => 'सितंबर';

  @override
  String get october => 'अक्टूबर';

  @override
  String get november => 'नवंबर';

  @override
  String get december => 'दिसंबर';

  @override
  String get ok => 'ठीक है';

  @override
  String get updateSuccessfullyInstalledTitle =>
      'अपडेट सफलतापूर्वक इंस्टॉल किया गया';

  @override
  String get updateSuccessfullyInstalledDescription =>
      'बर्थडे कैलेंडर को सफलतापूर्वक अपडेट कर दिया गया है! 🎂';

  @override
  String get tryAgain => 'फिर से प्रयास करें?';

  @override
  String get dismiss => 'खारिज करें';

  @override
  String get updateFailedToInstallTitle => 'अपडेट इंस्टॉल करने में विफल ❌';

  @override
  String updateFailedToInstallDescription(Object error) {
    return 'बर्थडे कैलेंडर अपडेट करने में विफल रहा क्योंकि: $error';
  }

  @override
  String get userDeniedUpdate => 'उपयोगकर्ता ने अपडेट अस्वीकार कर दिया';

  @override
  String get appUpdateFailed => 'ऐप अपडेट असफल रहा';

  @override
  String get darkMode => 'डार्क मोड';

  @override
  String get importContacts => 'संपर्क आयात करें';

  @override
  String get clearNotifications => 'सूचनाएँ साफ़ करें';

  @override
  String get clearNotificationsAlertTitle => 'क्या आप सुनिश्चित हैं?';

  @override
  String get clearNotificationsAlertDescription =>
      'क्या आप सभी सूचनाएं हटाना चाहते हैं?';

  @override
  String get no => 'नहीं';

  @override
  String get yes => 'हाँ';

  @override
  String get addPhoneNumber => 'फोन नंबर जोड़ें';

  @override
  String get add => 'जोड़ें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get back => 'वापस';

  @override
  String get proceed => 'आगे बढ़ें';

  @override
  String get hintTextForNameInputField => 'नाम?';

  @override
  String get notValidName => 'कृपया एक मान्य नाम दर्ज करें';

  @override
  String get nameAlreadyExists => 'इस नाम से एक जन्मदिन पहले से मौजूद है';

  @override
  String birthdaysForDayAndMonth(Object day, Object month) {
    return '$day $month के लिए जन्मदिन';
  }

  @override
  String helpTextChooseBirthdateForImportedContact(Object contactName) {
    return '$contactName के लिए जन्मतिथि चुनें';
  }

  @override
  String fieldLabelTextChooseBirthdateForImportedContact(Object contactName) {
    return '$contactName की जन्मतिथि';
  }

  @override
  String notificationForBirthdayMessage(Object contactName) {
    return '$contactName का जन्मदिन आने वाला है!';
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
}
