import 'package:birthday_calendar/BirthdayBloc/BirthdaysBloc.dart';
import 'package:birthday_calendar/UserNotificationStatusBloc/UserNotificationStatusBloc.dart';
import 'package:birthday_calendar/l10n/app_localizations.dart';
import 'package:birthday_calendar/service/notification_service/notification_service.dart';
import 'package:birthday_calendar/service/storage_service/shared_preferences_storage.dart';
import 'package:birthday_calendar/utils.dart';
import 'package:flutter/material.dart';
import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:url_launcher/url_launcher.dart';

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

  void _handleCallButtonPressed(
      BuildContext context, String phoneNumber) async {
    Uri phoneUri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(phoneUri)) {
      launchUrl(phoneUri);
    } else {
      Utils.showSnackbarWithMessage(
          context, AppLocalizations.of(context)!.unableToMakeCallMsg);
    }
  }

  void _handleAddingPhoneNumber(BuildContext context) async {
    PhoneNumber _birthdayPhoneNumber = PhoneNumber(isoCode: 'US');
    final _phoneNumberKey = GlobalKey<FormFieldState>();
    TextEditingController _phoneNumberController = new TextEditingController();

    AlertDialog addPhoneNumberAlert = AlertDialog(
        title: Text(AppLocalizations.of(context)!.addPhoneNumber),
        content: InternationalPhoneNumberInput(
          key: _phoneNumberKey,
          onInputChanged: (PhoneNumber number) {
            _birthdayPhoneNumber = number;
          },
          onInputValidated: (bool value) {},
          selectorConfig: SelectorConfig(
            selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
          ),
          ignoreBlank: false,
          autoValidateMode: AutovalidateMode.disabled,
          initialValue: _birthdayPhoneNumber,
          textFieldController: _phoneNumberController,
          formatInput: false,
          keyboardType:
              TextInputType.numberWithOptions(signed: true, decimal: true),
          inputBorder: OutlineInputBorder(),
          onSaved: (PhoneNumber number) {
            _birthdayPhoneNumber = number;
          },
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            onPressed: () {
              if (_birthdayPhoneNumber.phoneNumber != null) {
                String phone = _birthdayPhoneNumber.parseNumber();
                birthdayOfPerson.phoneNumber = phone;
                context
                    .read<StorageServiceSharedPreferences>()
                    .updatePhoneNumberForBirthday(birthdayOfPerson);
                setState(() {});
                _phoneNumberController.clear();
                Navigator.pop(context);
              } else {
                return null;
              }
            },
            child: Text(AppLocalizations.of(context)!.add),
          ),
          TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () {
                _phoneNumberController.clear();
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context)!.cancel)),
        ]);

    showDialog(
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
              _handleCallButtonPressed(context, birthdayOfPerson.phoneNumber);
            })
        : new IconButton(
            icon: Icon(Icons.add_ic_call_outlined,
                color: Utils.getColorBasedOnPosition(
                    indexOfBirthday, ElementType.icon)),
            onPressed: () {
              _handleAddingPhoneNumber(context);
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
                  context.read<StorageServiceSharedPreferences>(),
                  notificationService),
              child: BlocBuilder<UserNotificationStatusBloc, bool>(
                  builder: (context, state) {
                return new IconButton(
                    icon: Icon(
                        !birthdayOfPerson.hasNotification
                            ? Icons.notifications_off_outlined
                            : Icons.notifications_active_outlined,
                        color: Utils.getColorBasedOnPosition(
                            indexOfBirthday, ElementType.icon)),
                    onPressed: () {
                      BlocProvider.of<UserNotificationStatusBloc>(context).add(
                          new UserNotificationStatusEvent(
                              userBirthday: birthdayOfPerson,
                              hasNotification: birthdayOfPerson.hasNotification,
                              notificationMsg: AppLocalizations.of(context)!
                                  .notificationForBirthdayMessage(
                                      birthdayOfPerson.name)));
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
