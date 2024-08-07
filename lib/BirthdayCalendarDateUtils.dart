


import 'package:birthday_calendar/constants.dart';
import 'package:intl/intl.dart';

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
}