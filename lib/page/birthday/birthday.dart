import 'dart:async';
import 'package:birthday_calendar/birthday_bloc/birthdays_bloc.dart';
import 'package:birthday_calendar/user_notification_status_bloc/user_notification_status_bloc.dart';
import 'package:birthday_calendar/l10n/app_localizations.dart';
import 'package:birthday_calendar/service/notification_service/notification_service.dart';
import 'package:birthday_calendar/service/storage_service/storage_service.dart';
import 'package:birthday_calendar/utils.dart';
import 'package:flutter/material.dart';
import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:material_ui/material_ui.dart' as mui;

class BirthdayWidget extends StatefulWidget {
  final UserBirthday birthdayOfPerson;
  final int indexOfBirthday;
  final NotificationService notificationService;

  BirthdayWidget(
      {required Key key,
      required this.birthdayOfPerson,
      required this.indexOfBirthday,
      required this.notificationService})
      : super(key: key);

  @override
  _BirthdayWidgetState createState() => _BirthdayWidgetState(
      notificationService, birthdayOfPerson, indexOfBirthday);
}

class _BirthdayWidgetState extends State<BirthdayWidget> {
  _BirthdayWidgetState(
      this.notificationService, this.birthdayOfPerson, this.indexOfBirthday);

  NotificationService notificationService;
  UserBirthday birthdayOfPerson;
  int indexOfBirthday;

  Future<void> _handleCallButtonPressed(
      BuildContext context, String phoneNumber) async {
    Uri phoneUri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (!mounted) return;
      Utils.showSnackbarWithMessage(
          context, AppLocalizations.of(context)!.unableToMakeCallMsg);
    }
  }

  Future<void> _handleAddingPhoneNumber(BuildContext context) async {
    PhoneNumber? chosenNumber;

    AlertDialog addPhoneNumberAlert = AlertDialog(
        title: Text(AppLocalizations.of(context)!.addPhoneNumber),
        content: mui.Material(
          type: mui.MaterialType.transparency,
          child:
          PhoneFormField(
              initialValue: PhoneNumber.parse('+1'),
              onChanged: (number) {
                chosenNumber = number;
              },
              countrySelectorNavigator:
              const CountrySelectorNavigator.draggableBottomSheet()
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            onPressed: () async {
              final number = chosenNumber;
              if (number != null && number.nsn.isNotEmpty) {
                final storageService = context.read<StorageService>();
                final navigator = Navigator.of(context);
                birthdayOfPerson.phoneNumber = number.international;
                await storageService
                    .updatePhoneNumberForBirthday(birthdayOfPerson);
                if (!mounted) return;
                setState(() {});
                navigator.pop();
              }
            },
            child: Text(AppLocalizations.of(context)!.add),
          ),
          TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel)),
        ]);

    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return addPhoneNumberAlert;
        });
  }

  Widget callIconButton(BuildContext context) {
    return birthdayOfPerson.phoneNumber.isNotEmpty
        ? new IconButton(
            icon: Icon(Icons.call,
                color: Utils.getColorBasedOnPosition(
                    indexOfBirthday, ElementType.icon)),
            onPressed: () {
              unawaited(_handleCallButtonPressed(
                  context, birthdayOfPerson.phoneNumber));
            })
        : new IconButton(
            icon: Icon(Icons.add_ic_call_outlined,
                color: Utils.getColorBasedOnPosition(
                    indexOfBirthday, ElementType.icon)),
            onPressed: () {
              unawaited(_handleAddingPhoneNumber(context));
            });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      color: Utils.getColorBasedOnPosition(
          indexOfBirthday, ElementType.background),
      child: Row(
        children: [
          new Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              birthdayOfPerson.name,
              textDirection: TextDirection.ltr,
              style: new TextStyle(
                  fontSize: 20.0,
                  color: Utils.getColorBasedOnPosition(
                      indexOfBirthday, ElementType.text)),
            ),
          ),
          new Spacer(),
          BlocProvider(
              create: (context) => UserNotificationStatusBloc(
                  context.read<StorageService>(),
                  notificationService,
                  birthdayOfPerson.hasNotification),
              child: BlocBuilder<UserNotificationStatusBloc,
                  UserNotificationStatusState>(builder: (context, state) {
                return new IconButton(
                    icon: Icon(
                        !state.hasNotification
                            ? Icons.notifications_off_outlined
                            : Icons.notifications_active_outlined,
                        color: Utils.getColorBasedOnPosition(
                            indexOfBirthday, ElementType.icon)),
                    onPressed: () async {
                      if (!state.hasNotification) {
                        final userNotificationStatusBloc =
                            BlocProvider.of<UserNotificationStatusBloc>(
                                context);
                        final localizations = AppLocalizations.of(context)!;

                        PermissionStatus status = await notificationService
                            .getNotificationPermissionStatus();

                        if (!context.mounted) return;

                        if (status == PermissionStatus.denied) {
                          bool showRationale = await notificationService
                              .shouldShowNotificationRationale();
                          if (showRationale && context.mounted) {
                            await Utils.showAlertDialog(
                                context,
                                localizations.appTitle,
                                localizations.notificationPermissionRationale,
                                localizations.ok);
                          }

                          if (!context.mounted) return;

                          status = await notificationService
                              .requestNotificationPermission();
                        }

                        if (!mounted) return;

                        if (status.isGranted) {
                          userNotificationStatusBloc
                              .add(UserNotificationStatusToggled(
                            userBirthday: birthdayOfPerson,
                            notificationMsg:
                                localizations.notificationForBirthdayMessage(
                                    birthdayOfPerson.name),
                          ));
                          return;
                        }

                        if (status.isPermanentlyDenied) {
                          Utils.showSnackbarWithMessageAndAction(
                              context,
                              localizations
                                  .notificationPermissionPermanentlyDenied,
                              SnackBarAction(
                                  label: localizations.openSettings,
                                  onPressed: openAppSettings));
                          return;
                        }

                        Utils.showSnackbarWithMessage(context,
                            localizations.notificationPermissionDenied);
                      } else {
                        BlocProvider.of<UserNotificationStatusBloc>(context)
                            .add(UserNotificationStatusToggled(
                          userBirthday: birthdayOfPerson,
                          notificationMsg: AppLocalizations.of(context)!
                              .notificationForBirthdayMessage(
                                  birthdayOfPerson.name),
                        ));
                      }
                    });
              })),
          callIconButton(context),
          new IconButton(
              icon: Icon(Icons.clear,
                  color: Utils.getColorBasedOnPosition(
                      indexOfBirthday, ElementType.icon)),
              onPressed: () {
                BlocProvider.of<BirthdaysBloc>(context).add(new BirthdaysEvent(
                    eventName: BirthdayEvent.RemoveBirthday,
                    birthday: birthdayOfPerson));
              }),
        ],
      ),
    );
  }
}
