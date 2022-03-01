
abstract class DateService {
  int getCurrentMonthNumber();
  String convertMonthToWord(int month);
  String getCurrentMonthName();
  int amountOfDaysInMonth(String month);
  bool isLeapYear();
  String getWeekdayNameFromDate(DateTime date);
  DateTime constructDateTimeFromDayAndMonth(int day, int month);
  String formatDateForSharedPrefs(DateTime date);
}