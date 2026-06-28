import 'dart:async';
import 'package:birthday_calendar/BirthdayCalendarDateUtils.dart';
import 'package:birthday_calendar/ClearNotificationsBloc/ClearNotificationsBloc.dart';
import 'package:birthday_calendar/ContactsPermissionStatusBloc/ContactsPermissionStatusBloc.dart';
import 'package:birthday_calendar/VersionBloc/VersionBloc.dart';
import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:birthday_calendar/page/birthdays_for_calendar_day_page/birthdays_for_calendar_day.dart';
import 'package:birthday_calendar/service/contacts_service/contacts_service.dart';
import 'package:birthday_calendar/service/notification_service/notificationCallbacks.dart';
import 'package:birthday_calendar/service/notification_service/notification_service.dart';
import 'package:birthday_calendar/service/storage_service/storage_service.dart';
import 'package:birthday_calendar/service/update_service/update_service.dart';
import 'package:birthday_calendar/service/update_service/update_service_impl.dart';
import 'package:birthday_calendar/service/version_specific_service/VersionSpecificService.dart';
import 'package:birthday_calendar/service/version_specific_service/VersionSpecificServiceImpl.dart';
import 'package:birthday_calendar/utils.dart';
import 'package:flutter/material.dart';
import 'package:birthday_calendar/page/settings_page/settings_screen.dart';
import 'package:birthday_calendar/widget/calendar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:birthday_calendar/l10n/app_localizations.dart';

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

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (details.primaryVelocity == null) return;
    if (details.primaryVelocity! > 0) {
      _calculateNextMonthToShow(AxisDirection.right);
    } else if (details.primaryVelocity! < 0) {
      _calculateNextMonthToShow(AxisDirection.left);
    }
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
    super.initState();
    versionSpecificService = new VersionSpecificServiceImpl(
        storageService: context.read<StorageService>(),
        notificationService: notificationService);

    unawaited(_initializeServices());

    monthToPresent = widget.currentMonth;
    widget.notificationService.addListenerForSelectNotificationStream(this);
    _updateService.checkForInAppUpdate(
        _onUpdateSuccess, _onUpdateFailure, context);
    BlocProvider.of<ContactsPermissionStatusBloc>(context)
        .add(ContactsPermissionStatusEvent.PermissionUnknown);
    BlocProvider.of<VersionBloc>(context).add(VersionEvent.versionUnknown);
  }

  Future<void> _initializeServices() async {
    try {
      await versionSpecificService.migrateNotificationStatus();
    } catch (e, stackTrace) {
      debugPrint("Failed to migrate notification status: $e\n$stackTrace");
    }

    if (!mounted) return;

    // Track whether init succeeded — the ID migration cancels and reschedules
    // all notifications, so it must not run if the notification service is
    // not properly initialised.
    bool notificationInitSucceeded = false;
    try {
      await widget.notificationService.init(context);
      notificationInitSucceeded = true;
    } catch (e, stackTrace) {
      debugPrint("Failed to initialize notification service: $e\n$stackTrace");
    }

    if (!mounted) return;

    if (!notificationInitSucceeded) return;

    try {
      // Capture the localizations instance synchronously before crossing any
      // await boundary — using context after an await is unsafe if the widget
      // has been unmounted or the localization scope has changed.
      final localizations = AppLocalizations.of(context)!;
      await versionSpecificService.migrateNotificationIds(
        (name) => localizations.notificationForBirthdayMessage(name),
      );
    } catch (e, stackTrace) {
      debugPrint("Failed to migrate notification IDs: $e\n$stackTrace");
    }

    if (!mounted) return;

    try {
      // Fetch live contacts once and pass them into the migration so
      // the service layer does not need a BuildContext or a contacts-permission
      // check of its own. If contacts permission has not been granted yet the
      // fetch will return an empty list and the migration will be a no-op,
      // retrying on the next launch.
      final contacts = await widget.contactsService.fetchContacts(false);
      await versionSpecificService.migrateContactIds(contacts);
    } catch (e, stackTrace) {
      debugPrint("Failed to migrate contact IDs: $e\n$stackTrace");
    }
  }

  @override
  void didUpdateWidget(covariant MainPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    monthToPresent = widget.currentMonth;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClearNotificationsBloc, ClearNotificationsState>(
        builder: (context, state) {
      return Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                icon: Icon(
                  Icons.settings,
                ),
                onPressed: () {
                  unawaited(Navigator.push(context,
                      MaterialPageRoute(builder: (context) {
                    return SettingsScreen(
                        contactsService: widget.contactsService);
                  })).then((result) {}));
                },
              )
            ],
          ),
          body: BlocListener<ClearNotificationsBloc, ClearNotificationsState>(
            listener: (context, state) {
              if (state is ClearNotificationsCompleted) {
                setState(() {});
              }
            },
            child: new GestureDetector(
                onHorizontalDragEnd: _onHorizontalDragEnd,
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
                                      monthToPresent,
                                      AppLocalizations.of(context)!),
                              style: new TextStyle(
                                  fontSize: 25.0, fontWeight: FontWeight.bold))
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
                              _calculateNextMonthToShow(AxisDirection.right);
                            }),
                        new Expanded(
                          child: new CalendarWidget(
                              key: Key(monthToPresent.toString()),
                              currentMonth: monthToPresent,
                              notificationService: widget.notificationService),
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
    });
  }

  @override
  void dispose() {
    context.read<StorageService>().dispose();
    widget.notificationService.removeListenerForSelectNotificationStream(this);
    super.dispose();
  }

  @override
  Future<void> onNotificationSelected(String? payload) async {
    if (payload != null) {
      UserBirthday? birthday = Utils.getUserBirthdayFromPayload(payload);
      if (birthday != null) {
        List<UserBirthday> birthdays = await context
            .read<StorageService>()
            .getBirthdaysForDate(birthday.birthdayDate, true);

        if (!mounted) return;

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
