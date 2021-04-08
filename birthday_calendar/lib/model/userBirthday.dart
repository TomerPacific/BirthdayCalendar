
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
        name = json['name'],
        birthdayDate = json['birthdayDate'],
        hasNotification = json['hasNotification'];

  Map<String, dynamic> toJson() => {
    'name': name,
    'birthdayDate': birthdayDate,
    'hasNotification': hasNotification
 };
}