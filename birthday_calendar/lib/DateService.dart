import 'constants.dart';

class DateService {
  static final DateService _dateService = DateService._internal();

  factory DateService() {
    return _dateService;
  }

  DateService._internal();


  int getCurrentMonth() {
    DateTime now = new DateTime.now();
    return now.month;
  }

  String convertMonthToWord(int month) {
    return MONTHS[month];
  }

  int amountOfDaysInMonth(String month) {
    int days = 0;
    switch(month) {
      case "January":
      case "March":
      case "May":
      case "July":
      case "August":
      case "October":
      case "December": {
        days = 31;
        break;
      }
      case "April":
      case "June":
      case "September":
      case "November": {
        days = 30;
        break;
      }
      case "February": {
        days = isLeapYear() ? 29 : 28;
        break;
      }
    }

    return days;
  }

  bool isLeapYear() {
    DateTime now = new DateTime.now();
    int year = now.year;
    if (year % 4 == 0 && year % 100 != 0) {
      return true;
    } else if (year % 4 == 0 &&
               year % 100 == 0 &&
              year % 400 == 0) {
      return true;
    }
    return false;
  }

}