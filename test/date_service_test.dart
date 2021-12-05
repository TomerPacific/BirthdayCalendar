import 'package:flutter_test/flutter_test.dart';
import 'package:birthday_calendar/service/date_service.dart';

void main() {
  test("DateService convert month number 8 to August", () {
    final int monthNumber = 8;
    final String monthName = DateService().convertMonthToWord(monthNumber);
    expect(monthName, equals("August"));
  });

  test("DateService invalid month number returns empty string", () {
    final int monthNumber = 14;
    final String monthName = DateService().convertMonthToWord(monthNumber);
    expect(monthName, isEmpty);
  });

  test("DateService get amount of days in month with 30 days", () {
    final String monthName = "September";
    final int amountOfDays = DateService().amountOfDaysInMonth(monthName);
    expect(amountOfDays, equals(30));
  });

  test("DateService get amount of days in invalid month will be equal to zero", () {
    final String monthName = "New Month";
    final int amountOfDays = DateService().amountOfDaysInMonth(monthName);
    expect(amountOfDays, equals(0));
  });
}
