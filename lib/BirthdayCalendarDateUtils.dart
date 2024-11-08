import 'package:birthday_calendar/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BirthdayCalendarDateUtils {
  static int getCurrentMonthNumber() {
    DateTime now = new DateTime.now();
    return now.month;
  }

  static int amountOfDaysInMonth(int month) {
    int days = 0;
    switch (month) {
      case JANUARY_MONTH_NUMBER:
      case MARCH_MONTH_NUMBER:
      case MAY_MONTH_NUMBER:
      case JULY_MONTH_NUMBER:
      case AUGUST_MONTH_NUMBER:
      case OCTOBER_MONTH_NUMBER:
      case DECEMBER_MONTH_NUMBER:
        {
          days = 31;
          break;
        }
      case APRIL_MONTH_NUMBER:
      case JUNE_MONTH_NUMBER:
      case SEPTEMBER_MONTH_NUMBER:
      case NOVEMBER_MONTH_NUMBER:
        {
          days = 30;
          break;
        }
      case FEBRUARY_MONTH_NUMBER:
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
      int month, BuildContext context) {
    switch (month) {
      case JANUARY_MONTH_NUMBER:
        return AppLocalizations.of(context)!.january;
      case FEBRUARY_MONTH_NUMBER:
        return AppLocalizations.of(context)!.february;
      case MARCH_MONTH_NUMBER:
        return AppLocalizations.of(context)!.march;
      case APRIL_MONTH_NUMBER:
        return AppLocalizations.of(context)!.april;
      case MAY_MONTH_NUMBER:
        return AppLocalizations.of(context)!.may;
      case JUNE_MONTH_NUMBER:
        return AppLocalizations.of(context)!.june;
      case JULY_MONTH_NUMBER:
        return AppLocalizations.of(context)!.july;
      case AUGUST_MONTH_NUMBER:
        return AppLocalizations.of(context)!.august;
      case SEPTEMBER_MONTH_NUMBER:
        return AppLocalizations.of(context)!.september;
      case OCTOBER_MONTH_NUMBER:
        return AppLocalizations.of(context)!.october;
      case NOVEMBER_MONTH_NUMBER:
        return AppLocalizations.of(context)!.november;
      case DECEMBER_MONTH_NUMBER:
        return AppLocalizations.of(context)!.december;
      default:
        return "";
    }
  }
}
