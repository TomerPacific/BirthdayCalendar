import 'package:intl/intl.dart';
import 'package:birthday_calendar/l10n/app_localizations.dart';

class BirthdayCalendarDateUtils {
  static int getCurrentMonthNumber() {
    DateTime now = new DateTime.now();
    return now.month;
  }

  static int amountOfDaysInMonth(int month) {
    int days = 0;
    switch (month) {
      case DateTime.january:
      case DateTime.march:
      case DateTime.may:
      case DateTime.july:
      case DateTime.august:
      case DateTime.october:
      case DateTime.december:
        {
          days = 31;
          break;
        }
      case DateTime.april:
      case DateTime.june:
      case DateTime.september:
      case DateTime.november:
        {
          days = 30;
          break;
        }
      case DateTime.february:
        {
          days = isLeapYear() ? 29 : 28;
          break;
        }
    }

    return days;
  }

  static bool isLeapYear() {
    DateTime now = new DateTime.now();
    int year = now.year;
    if (year % 4 == 0 && year % 100 != 0) {
      return true;
    } else if (year % 4 == 0 && year % 100 == 0 && year % 400 == 0) {
      return true;
    }
    return false;
  }

  static String getWeekdayNameFromDate(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  static DateTime constructDateTimeFromDayAndMonth(int day, int month) {
    int year = new DateTime.now().year;
    String paddedMonth = month < 10 ? "0" + month.toString() : month.toString();
    String paddedDay = day < 10 ? "0" + day.toString() : day.toString();
    String wholeDate = year.toString() + "-$paddedMonth-$paddedDay";
    return DateTime.parse(wholeDate);
  }

  static String formatDateForSharedPrefs(DateTime date) {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    return dateFormat.format(date);
  }

  static bool isADate(String date) {
    bool isValidDate = true;
    try {
      DateTime.parse(date);
    } catch (exception) {
      isValidDate = false;
    }

    return isValidDate;
  }

  static String convertAndTranslateMonthNumber(
      int month, AppLocalizations appLocalizations) {
    switch (month) {
      case DateTime.january:
        return appLocalizations.january;
      case DateTime.february:
        return appLocalizations.february;
      case DateTime.march:
        return appLocalizations.march;
      case DateTime.april:
        return appLocalizations.april;
      case DateTime.may:
        return appLocalizations.may;
      case DateTime.june:
        return appLocalizations.june;
      case DateTime.july:
        return appLocalizations.july;
      case DateTime.august:
        return appLocalizations.august;
      case DateTime.september:
        return appLocalizations.september;
      case DateTime.october:
        return appLocalizations.october;
      case DateTime.november:
        return appLocalizations.november;
      case DateTime.december:
        return appLocalizations.december;
      default:
        return "";
    }
  }
}
