
import 'package:birthday_calendar/constants.dart';

class UserBirthday {
  final String name;
  final String birthdayDate;
  bool hasNotification;

  UserBirthday(this.name, this.birthdayDate, this.hasNotification);

  void updateNotificationStatus(bool status) {
    this.hasNotification = status;
  }

  bool equals(UserBirthday otherBirthday) {
    return (this.name == otherBirthday.name &&
            this.birthdayDate == otherBirthday.birthdayDate);
  }

  UserBirthday.fromJson(Map<String, dynamic> json) :
        name = json[USER_BIRTHDAY_NAME_KEY],
        birthdayDate = json[USER_BIRTHDAY_DATE_KEY],
        hasNotification = json[USER_BIRTHDAY_NOTIFICATION_KEY];

  Map<String, dynamic> toJson() => {
    USER_BIRTHDAY_NAME_KEY : name,
    USER_BIRTHDAY_DATE_KEY : birthdayDate,
    USER_BIRTHDAY_NOTIFICATION_KEY : hasNotification
 };
}