import 'package:birthday_calendar/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BirthdayCalendarDateUtils {

  static int getCurrentMonthNumber() {
    DateTime now = new DateTime.now();
    return now.month;
  }

  static String convertMonthToWord(int month) {
    String? monthName = months[month];
    return monthName != null ? monthName : "";
  }

  static String getCurrentMonthName() {
    return convertMonthToWord(getCurrentMonthNumber());
  }

  static int amountOfDaysInMonth(String month) {
    int days = 0;
    switch (month) {
      case "January":
      case "March":
      case "May":
      case "July":
      case "August":
      case "October":
      case "December":
        {
          days = 31;
          break;
        }
      case "April":
      case "June":
      case "September":
      case "November":
        {
          days = 30;
          break;
        }
      case "February":
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
    } catch(exception) {
      isValidDate = false;
    }

    return isValidDate;
  }

  static String translateMonth(int month, BuildContext context) {
         switch (month) {
            case 1:
              return AppLocalizations.of(context)!.january;
            case 2:
              return AppLocalizations.of(context)!.february;
            case 3:
              return AppLocalizations.of(context)!.march;
            case 4:
              return AppLocalizations.of(context)!.april;
            case 5:
              return AppLocalizations.of(context)!.may;
            case 6:
              return AppLocalizations.of(context)!.june;
            case 7:
              return AppLocalizations.of(context)!.july;
            case 8:
              return AppLocalizations.of(context)!.august;
            case 9:
              return AppLocalizations.of(context)!.september;
            case 10:
              return AppLocalizations.of(context)!.october;
            case 11:
              return AppLocalizations.of(context)!.november;
            case 12:
              return AppLocalizations.of(context)!.december;
            default:
              return "";
          }
    }
}