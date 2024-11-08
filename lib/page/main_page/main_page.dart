import 'package:birthday_calendar/BirthdayCalendarDateUtils.dart';
import 'package:birthday_calendar/ClearNotificationsBloc/ClearNotificationsBloc.dart';
import 'package:birthday_calendar/ContactsPermissionStatusBloc/ContactsPermissionStatusBloc.dart';
import 'package:birthday_calendar/VersionBloc/VersionBloc.dart';
import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:birthday_calendar/page/birthdays_for_calendar_day_page/birthdays_for_calendar_day.dart';
import 'package:birthday_calendar/service/contacts_service/contacts_service.dart';
import 'package:birthday_calendar/service/notification_service/notificationCallbacks.dart';
import 'package:birthday_calendar/service/notification_service/notification_service.dart';
import 'package:birthday_calendar/service/storage_service/shared_preferences_storage.dart';
import 'package:birthday_calendar/service/update_service/update_service.dart';
import 'package:birthday_calendar/service/update_service/update_service_impl.dart';
import 'package:birthday_calendar/service/version_specific_service/VersionSpecificService.dart';
import 'package:birthday_calendar/service/version_specific_service/VersionSpecificServiceImpl.dart';
import 'package:birthday_calendar/utils.dart';
import 'package:flutter/material.dart';
import 'package:birthday_calendar/page/settings_page/settings_screen.dart';
import 'package:birthday_calendar/widget/calendar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MainPage extends StatefulWidget {
  MainPage(
      {required Key key,
      required this.notificationService,
      required this.contactsService,
      required this.title,
      required this.currentMonth})
      : super(key: key);

  final String title;
  final int currentMonth;
  final NotificationService notificationService;
  final ContactsService contactsService;

  @override
  _MainPageState createState() => _MainPageState(notificationService);
}

class _MainPageState extends State<MainPage> implements NotificationCallbacks {
  _MainPageState(this.notificationService);

  int monthToPresent = -1;
  NotificationService notificationService;
  UpdateService _updateService = UpdateServiceImpl();
  late VersionSpecificService versionSpecificService;

  void _calculateNextMonthToShow(AxisDirection direction) {
    setState(() {
      monthToPresent = direction == AxisDirection.left
          ? monthToPresent + 1
          : monthToPresent - 1;
      monthToPresent = Utils.correctMonthOverflow(monthToPresent);
    });
  }

  void _decideOnNextMonthToShow(DragUpdateDetails details) {
    details.delta.dx > 0
        ? _calculateNextMonthToShow(AxisDirection.right)
        : _calculateNextMonthToShow(AxisDirection.left);
  }

  void _onUpdateSuccess() {
    Widget alertDialogOkButton = TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text(AppLocalizations.of(context)!.ok));
    AlertDialog alertDialog = AlertDialog(
      title:
          Text(AppLocalizations.of(context)!.updateSuccessfullyInstalledTitle),
      content: Text(
          AppLocalizations.of(context)!.updateSuccessfullyInstalledDescription),
      actions: [alertDialogOkButton],
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alertDialog;
        });
  }

  void _onUpdateFailure(String error) {
    Widget alertDialogTryAgainButton = TextButton(
        onPressed: () {
          _updateService.checkForInAppUpdate(
              _onUpdateSuccess, _onUpdateFailure, context);
          Navigator.pop(context);
        },
        child: Text(AppLocalizations.of(context)!.tryAgain));
    Widget alertDialogCancelButton = TextButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: Text(AppLocalizations.of(context)!.dismiss),
    );
    AlertDialog alertDialog = AlertDialog(
      title: Text(AppLocalizations.of(context)!.updateFailedToInstallTitle),
      content: Text(AppLocalizations.of(context)!
          .updateFailedToInstallDescription(error)),
      actions: [alertDialogTryAgainButton, alertDialogCancelButton],
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alertDialog;
        });
  }

  @override
  void initState() {
    versionSpecificService = new VersionSpecificServiceImpl(
        storageService: context.read<StorageServiceSharedPreferences>(),
        notificationService: notificationService);
    monthToPresent = widget.currentMonth;
    widget.notificationService.init(context);
    widget.notificationService.addListenerForSelectNotificationStream(this);
    _updateService.checkForInAppUpdate(
        _onUpdateSuccess, _onUpdateFailure, context);
    BlocProvider.of<ContactsPermissionStatusBloc>(context)
        .add(ContactsPermissionStatusEvent.PermissionUnknown);
    BlocProvider.of<VersionBloc>(context).add(VersionEvent.versionUnknown);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant MainPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    monthToPresent = widget.currentMonth;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => ClearNotificationsBloc(
            context.read<StorageServiceSharedPreferences>()),
        child: BlocBuilder<ClearNotificationsBloc, bool>(
            builder: (context, state) {
          return Scaffold(
              appBar: AppBar(
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.settings,
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                        return BlocProvider.value(
                            value: BlocProvider.of<ClearNotificationsBloc>(
                                context),
                            child: SettingsScreen(
                                contactsService: widget.contactsService));
                      })).then((result) {});
                    },
                  )
                ],
              ),
              body: BlocListener<ClearNotificationsBloc, bool>(
                listener: (context, state) {
                  if (state) {
                    setState(() {});
                  }
                },
                child: new GestureDetector(
                    onHorizontalDragUpdate: _decideOnNextMonthToShow,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        new Padding(
                          padding: const EdgeInsets.only(bottom: 50, top: 50),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              new Text(
                                  BirthdayCalendarDateUtils
                                      .convertAndTranslateMonthNumber(
                                          monthToPresent, AppLocalizations.of(context)!),
                                  style: new TextStyle(
                                      fontSize: 25.0,
                                      fontWeight: FontWeight.bold))
                            ],
                          ),
                        ),
                        new Expanded(
                            child: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            new IconButton(
                                icon: new Icon(Icons.chevron_left),
                                onPressed: () {
                                  _calculateNextMonthToShow(
                                      AxisDirection.right);
                                }),
                            new Expanded(
                              child: new CalendarWidget(
                                  key: Key(monthToPresent.toString()),
                                  currentMonth: monthToPresent,
                                  notificationService:
                                      widget.notificationService),
                            ),
                            new IconButton(
                                icon: new Icon(Icons.chevron_right),
                                onPressed: () {
                                  _calculateNextMonthToShow(AxisDirection.left);
                                }),
                          ],
                        ))
                      ],
                    )),
              ));
        }));
  }

  @override
  void dispose() {
    context.read<StorageServiceSharedPreferences>().dispose();
    widget.notificationService.removeListenerForSelectNotificationStream(this);
    super.dispose();
  }

  @override
  Future<void> onNotificationSelected(String? payload) async {
    if (payload != null) {
      UserBirthday? birthday = Utils.getUserBirthdayFromPayload(payload);
      if (birthday != null) {
        List<UserBirthday> birthdays = await context
            .read<StorageServiceSharedPreferences>()
            .getBirthdaysForDate(birthday.birthdayDate, true);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BirthdaysForCalendarDayWidget(
                  key: Key(birthday.birthdayDate.toString()),
                  dateOfDay: birthday.birthdayDate,
                  birthdays: birthdays,
                  notificationService: widget.notificationService),
            ));
      }
    }
  }
}
