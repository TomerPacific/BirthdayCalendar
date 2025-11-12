import 'package:birthday_calendar/BirthdayBloc/BirthdaysBloc.dart';
import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:birthday_calendar/service/notification_service/notification_service.dart';
import 'package:birthday_calendar/service/storage_service/shared_preferences_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:collection/collection.dart';
import 'package:birthday_calendar/l10n/app_localizations.dart';

class AddBirthdayForm extends StatefulWidget {
  final DateTime dateOfDay;
  final NotificationService notificationService;

  AddBirthdayForm(
      {Key? key, required this.dateOfDay, required this.notificationService})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AddBirthdayFormState();
  }
}

class AddBirthdayFormState extends State<AddBirthdayForm> {
  final _addBirthdayFormKey = GlobalKey<FormState>();
  final _birthdayNameKey = GlobalKey<FormFieldState>();
  final _phoneNumberKey = GlobalKey<FormFieldState>();

  TextEditingController _birthdayPersonController = new TextEditingController();
  TextEditingController _phoneNumberController = new TextEditingController();
  PhoneNumber _birthdayPhoneNumber = PhoneNumber(isoCode: 'US');
  List<UserBirthday> birthdaysForDate = [];
  bool doesWantToAddPhoneNumber = false;
  late FocusNode addTelephoneButtonFocusNode;

  bool _isUniqueName(String name) {
    UserBirthday? birthday =
        birthdaysForDate.firstWhereOrNull((element) => element.name == name);
    return birthday == null;
  }

  @override
  void initState() {
    super.initState();
    addTelephoneButtonFocusNode = FocusNode();
    _getBirthdaysForDate();
  }

  void _getBirthdaysForDate() async {
    birthdaysForDate = await context
        .read<StorageServiceSharedPreferences>()
        .getBirthdaysForDate(widget.dateOfDay, true);
  }

  Widget _phoneNumberInputField() {
    return doesWantToAddPhoneNumber == true
        ? new InternationalPhoneNumberInput(
            focusNode: addTelephoneButtonFocusNode,
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
          )
        : Spacer();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.addBirthday),
      content: Form(
          key: _addBirthdayFormKey,
          child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                new Row(
                  children: [
                    Expanded(
                      child: new TextFormField(
                        autofocus: true,
                        controller: _birthdayPersonController,
                        decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!
                                .hintTextForNameInputField),
                        key: _birthdayNameKey,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(context)!.notValidName;
                          }
                          if (!_isUniqueName(value)) {
                            return AppLocalizations.of(context)!
                                .nameAlreadyExists;
                          }
                          return null;
                        },
                      ),
                    ),
                    Expanded(
                        child: IconButton(
                      icon: doesWantToAddPhoneNumber == false
                          ? Icon(Icons.phone)
                          : Icon(Icons.phone, color: Colors.blueAccent),
                      onPressed: () {
                        setState(() {
                          doesWantToAddPhoneNumber = !doesWantToAddPhoneNumber;
                        });
                        addTelephoneButtonFocusNode.requestFocus();
                      },
                    ))
                  ],
                ),
                _phoneNumberInputField()
              ])),
      actions: [
        TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            onPressed: () async {
              if (_addBirthdayFormKey.currentState != null &&
                  _addBirthdayFormKey.currentState!.validate()) {
                _addBirthdayFormKey.currentState!.save();

                bool hasUserGrantedNotificationPermission = await widget
                    .notificationService
                    .isNotificationPermissionGranted(context);

                UserBirthday userBirthday = new UserBirthday(
                    _birthdayPersonController.text,
                    widget.dateOfDay,
                    hasUserGrantedNotificationPermission,
                    _birthdayPhoneNumber.phoneNumber != null
                        ? _birthdayPhoneNumber.parseNumber()
                        : "");
                BlocProvider.of<BirthdaysBloc>(context).add(new BirthdaysEvent(
                    eventName: BirthdayEvent.AddBirthday,
                    birthdays: birthdaysForDate,
                    birthday: userBirthday,
                    shouldShowAddBirthdayDialog: false,
                    notificationMsg: AppLocalizations.of(context)!
                        .notificationForBirthdayMessage(userBirthday.name)));

                Navigator.pop(context);
              } else {
                if (_birthdayNameKey.currentState != null &&
                    !_birthdayNameKey.currentState!.isValid) {
                  _birthdayPersonController.clear();
                }
                if (_phoneNumberKey.currentState != null &&
                    !_phoneNumberKey.currentState!.isValid) {
                  _birthdayPersonController.clear();
                }
              }
            },
            child: Text(AppLocalizations.of(context)!.ok)),
        TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              _birthdayPersonController.clear();
              _phoneNumberController.clear();
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.back))
      ],
    );
  }

  @override
  dispose() {
    _birthdayPersonController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }
}
