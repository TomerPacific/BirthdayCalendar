import 'package:birthday_calendar/ThemeBloc/ThemeBloc.dart';
import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:birthday_calendar/page/birthdays_for_calendar_day_page/birthdays_for_calendar_day.dart';
import 'package:birthday_calendar/page/main_page/main_screen_manager.dart';
import 'package:birthday_calendar/page/settings_page/settings_screen_manager.dart';
import 'package:birthday_calendar/service/notification_service/notificationCallbacks.dart';
import 'package:birthday_calendar/service/notification_service/notification_service_impl.dart';
import 'package:birthday_calendar/service/storage_service/storage_service.dart';
import 'package:birthday_calendar/service/update_service/update_service.dart';
import 'package:birthday_calendar/utils.dart';
import 'package:flutter/material.dart';
import 'package:birthday_calendar/page/settings_page/settings_screen.dart';
import 'package:birthday_calendar/widget/calendar.dart';
import 'package:birthday_calendar/service/date_service/date_service.dart';
import 'package:birthday_calendar/service/service_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  MainPage({required Key key, required this.title, required this.currentMonth}) : super(key: key);

  final String title;
  final int currentMonth;

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> implements NotificationCallbacks {

  int monthToPresent = -1;
  String month = "";
  DateService _dateService = getIt<DateService>();
  StorageService _storageService = getIt<StorageService>();
  UpdateService _updateService = getIt<UpdateService>();

  MainScreenManager _mainScreenManager = MainScreenManager();

  void _calculateNextMonthToShow(AxisDirection direction) {
    setState(() {
      monthToPresent = direction == AxisDirection.left ? monthToPresent + 1 : monthToPresent - 1;
      monthToPresent = _mainScreenManager.correctMonthOverflow(monthToPresent);
      month = _dateService.convertMonthToWord(monthToPresent);
    });
  }

  void _decideOnNextMonthToShow(DragUpdateDetails details) {
    details.delta.dx > 0 ?
    _calculateNextMonthToShow(AxisDirection.right) :
    _calculateNextMonthToShow(AxisDirection.left);
  }

  void _onUpdateSuccess() {
    Widget alertDialogOkButton = TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text("Ok")
    );
      AlertDialog alertDialog = AlertDialog(
        title: const Text("Update Successfully Installed"),
        content: const Text("Birthday Calendar has been updated successfully! 🎂"),
        actions: [
          alertDialogOkButton
        ],
      );
      showDialog(context: context,
          builder: (BuildContext context) {
        return alertDialog;
      });
  }

  void _onUpdateFailure(String error) {
    Widget alertDialogTryAgainButton = TextButton(
        onPressed: () {
          _updateService.checkForInAppUpdate(_onUpdateSuccess, _onUpdateFailure);
          Navigator.pop(context);
        },
        child: const Text("Try Again?")
    );
    Widget alertDialogCancelButton = TextButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: const Text("Dismiss"),
    );
    AlertDialog alertDialog = AlertDialog(
      title: const Text("Update Failed To Install ❌"),
      content: Text("Birthday Calendar has failed to update because: \n $error"),
      actions: [
        alertDialogTryAgainButton,
        alertDialogCancelButton
      ],
    );
    showDialog(context: context,
        builder: (BuildContext context) {
          return alertDialog;
        });
  }

  @override
  void initState()  {
    monthToPresent = widget.currentMonth;
    month = _dateService.convertMonthToWord(monthToPresent);
    RepositoryProvider.of<NotificationServiceImpl>(context).init();
    RepositoryProvider.of<NotificationServiceImpl>(context).addListenerForSelectNotificationStream(this);
    _mainScreenManager.makeVersionAdjustments();
    _updateService.checkForInAppUpdate(_onUpdateSuccess, _onUpdateFailure);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant MainPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    monthToPresent = widget.currentMonth;
    month = _dateService.convertMonthToWord(monthToPresent);
  }

  @override
  Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
              actions: [
                IconButton(
                    icon: Icon(
                         Icons.settings,
                          color: Colors.white,
                        ),
                  onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) {
                              return BlocProvider.value(
                                  value:BlocProvider.of<ThemeBloc>(context),
                                  child:SettingsScreen()
                              );
                          })).then((result) {
                          if (result == true) {
                            setState(() {});
                            Provider.of<SettingsScreenManager>(context, listen: false).setOnClearBirthdaysFlag(false);
                          }
                        });
                  },
               )
              ],
          ),
      body:
            new GestureDetector(
                onHorizontalDragUpdate: _decideOnNextMonthToShow,
                child:
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    new Padding(
                      padding: const EdgeInsets.only(bottom: 50, top: 50),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          new Text(month, style: new TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold))
                        ],
                      ),
                    ),
                    new Expanded(child:
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        new IconButton(icon:
                        new Icon(Icons.chevron_left),
                            onPressed: () {
                              _calculateNextMonthToShow(AxisDirection.right);
                            }),
                        new Expanded(child:
                        new CalendarWidget(
                            key: Key(monthToPresent.toString()),
                            currentMonth:monthToPresent),
                        ),
                        new IconButton(icon:
                        new Icon(Icons.chevron_right),
                            onPressed: () {
                              _calculateNextMonthToShow(AxisDirection.left);
                            }),
                      ],
                    )
                    )
                  ],
                )
            )
        );
      }

  @override void dispose() {
    _storageService.dispose();
    RepositoryProvider.of<NotificationServiceImpl>(context).removeListenerForSelectNotificationStream(this);
    super.dispose();
  }

  @override
  Future<void> onNotificationSelected(String? payload) async {
    if (payload != null) {
      UserBirthday? birthday = Utils.getUserBirthdayFromPayload(payload);
      if (birthday != null) {
        List<UserBirthday> birthdays = await _storageService.getBirthdaysForDate(birthday.birthdayDate, true);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BirthdaysForCalendarDayWidget(
                  key: Key(birthday.birthdayDate.toString()),
                  dateOfDay: birthday.birthdayDate,
                  birthdays: birthdays),
            ));
      }
    }
  }
}