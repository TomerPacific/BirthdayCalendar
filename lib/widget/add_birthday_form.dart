import 'package:birthday_calendar/birthday_bloc/birthdays_bloc.dart';
import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:birthday_calendar/service/notification_service/notification_service.dart';
import 'package:birthday_calendar/service/storage_service/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:collection/collection.dart';
import 'package:birthday_calendar/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart' as mui;

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

  TextEditingController _birthdayPersonController = new TextEditingController();
  PhoneNumber _birthdayPhoneNumber = PhoneNumber.parse('+1');
  List<UserBirthday> birthdaysForDate = [];
  bool doesWantToAddPhoneNumber = false;
  bool _isLoading = true;
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
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _getBirthdaysForDate();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getBirthdaysForDate() async {
    final storageService = context.read<StorageService>();
    try {
      birthdaysForDate =
          await storageService.getBirthdaysForDate(widget.dateOfDay, true);
    } catch (e) {
      debugPrint("Failed to fetch birthdays for date: $e");
    }
  }

  Widget _phoneNumberInputField() {
    return doesWantToAddPhoneNumber == true
        ? mui.Material(
      type: mui.MaterialType.transparency,
      child: PhoneFormField(
        focusNode: addTelephoneButtonFocusNode,
        initialValue: _birthdayPhoneNumber,
        onChanged: (number) {
          _birthdayPhoneNumber = number;
        },
        validator: PhoneValidator.compose([
          PhoneValidator.required(context),
          PhoneValidator.valid(context),
        ]),
        countrySelectorNavigator:
        const CountrySelectorNavigator.draggableBottomSheet(),
      ),
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
            onPressed: _isLoading
                ? null
                : () async {
                    if (_addBirthdayFormKey.currentState != null &&
                        _addBirthdayFormKey.currentState!.validate()) {
                      _addBirthdayFormKey.currentState!.save();

                      final localizations = AppLocalizations.of(context)!;
                      final birthdaysBloc =
                          BlocProvider.of<BirthdaysBloc>(context);
                      final navigator = Navigator.of(context);

                      final bool hasNotificationPermission = await widget
                          .notificationService
                          .isNotificationPermissionGranted();

                      if (!mounted) return;

                      UserBirthday userBirthday = new UserBirthday(
                          _birthdayPersonController.text,
                          widget.dateOfDay,
                          hasNotificationPermission,
                          doesWantToAddPhoneNumber && _birthdayPhoneNumber.nsn.isNotEmpty
                              ? _birthdayPhoneNumber.international
                              : "");
                      birthdaysBloc.add(new BirthdaysEvent(
                          eventName: BirthdayEvent.AddBirthday,
                          birthdays: birthdaysForDate,
                          birthday: userBirthday,
                          shouldShowAddBirthdayDialog: false,
                          notificationMsg:
                              localizations.notificationForBirthdayMessage(
                                  userBirthday.name)));

                      navigator.pop();
                    } else {
                      if (_birthdayNameKey.currentState != null &&
                          !_birthdayNameKey.currentState!.isValid) {
                        _birthdayPersonController.clear();
                      }
                    }
                  },
            child: Text(AppLocalizations.of(context)!.ok)),
        TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              _birthdayPersonController.clear();
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.back))
      ],
    );
  }

  @override
  dispose() {
    _birthdayPersonController.dispose();
    super.dispose();
  }
}
