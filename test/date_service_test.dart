import 'package:birthday_calendar/BirthdayCalendarDateUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {

    testWidgets('DateService convert month number 8 to August', (tester) async {
      await tester.pumpWidget(
        Localizations(
          locale: const Locale('en'),
          delegates: AppLocalizations.localizationsDelegates,
          child: Container(),
        ),
      );

      final BuildContext context = tester.element(find.byType(Container));

      final int monthNumber = 8;
      final String monthName = BirthdayCalendarDateUtils
          .convertAndTranslateMonthNumber(monthNumber, context);
      expect(monthName, "August");
    });

    testWidgets('DateService invalid month number returns empty string', (tester) async {
      await tester.pumpWidget(
        Localizations(
          locale: const Locale('en'),
          delegates: AppLocalizations.localizationsDelegates,
          child: Container(),
        ),
      );

      final BuildContext context = tester.element(find.byType(Container));

      final int monthNumber = 14;
      final String monthName = BirthdayCalendarDateUtils
          .convertAndTranslateMonthNumber(monthNumber, context);
      expect(monthName, "");
      });

      test("DateService get amount of days in month with 30 days", () {
        final int monthNumber = 9;
        final int amountOfDays = BirthdayCalendarDateUtils.amountOfDaysInMonth(
            monthNumber);
        expect(amountOfDays, 30);
      });

      test(
          "DateService get amount of days in invalid month will be equal to zero", () {
        final int monthNumber = 13;
        final int amountOfDays = BirthdayCalendarDateUtils.amountOfDaysInMonth(
            monthNumber);
        expect(amountOfDays, 0);
      });

      test(
          "DateService for the date of 5/12/21 we should get the day as Sunday", () {
        final DateTime dateTime = DateTime(2021, 12, 5);
        final String day = BirthdayCalendarDateUtils.getWeekdayNameFromDate(
            dateTime);
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
