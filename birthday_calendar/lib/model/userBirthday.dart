
class UserBirthday {
  final String name;
  final String birthdayDate;
  final bool hasNotification;

  UserBirthday(this.name, this.birthdayDate, this.hasNotification);

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