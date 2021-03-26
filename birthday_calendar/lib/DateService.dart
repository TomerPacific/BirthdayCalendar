
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

}