import 'package:flutter_test/flutter_test.dart';
import 'package:birthday_calendar/service/date_service.dart';

void main() {
  test("DateService convert month number 8 to August", () {
    final monthNumber = 8;
    final monthName = DateService().convertMonthToWord(monthNumber);
    expect(monthName, equals("August"));
  });

  test("DateService invalid month number returns empty string", () {
    final monthNumber = 14;
    final monthName = DateService().convertMonthToWord(monthNumber);
    expect(monthName, isEmpty);
  });
}
