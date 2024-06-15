import 'package:birthday_calendar/BirthdayCalendarDateUtils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  test("DateService convert month number 8 to August", () {
    final int monthNumber = 8;
    final String monthName = BirthdayCalendarDateUtils.convertMonthToWord(monthNumber);
    expect(monthName, "August");
  });

  test("DateService invalid month number returns empty string", () {
    final int monthNumber = 14;
    final String monthName = BirthdayCalendarDateUtils.convertMonthToWord(monthNumber);
    expect(monthName, "");
  });

  test("DateService get amount of days in month with 30 days", () {
    final String monthName = "September";
    final int amountOfDays = BirthdayCalendarDateUtils.amountOfDaysInMonth(monthName);
    expect(amountOfDays, 30);
  });

  test("DateService get amount of days in invalid month will be equal to zero", () {
    final String monthName = "New Month";
    final int amountOfDays = BirthdayCalendarDateUtils.amountOfDaysInMonth(monthName);
    expect(amountOfDays, 0);
  });

  test("DateService for the date of 5/12/21 we should get the day as Sunday", () {
    final DateTime dateTime = DateTime(2021, 12, 5);
    final String day = BirthdayCalendarDateUtils.getWeekdayNameFromDate(dateTime);
    expect(day, "Sunday");
  });

  test("DateService convert String representing actual date", () {
    final String date = "2020-01-04";
    final bool isAValidDate = BirthdayCalendarDateUtils.isADate(date);
    expect(isAValidDate, true);
  });

  test("DateService convert String NOT representing date", () {
    final String date = "Hello World!";
    final bool isAValidDate = BirthdayCalendarDateUtils.isADate(date);
    expect(isAValidDate, false);
  });
}
