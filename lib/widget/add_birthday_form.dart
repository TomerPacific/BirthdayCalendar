import 'package:birthday_calendar/BirthdayBloc/BirthdaysBloc.dart';
import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:birthday_calendar/service/storage_service/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:collection/collection.dart';
import 'package:birthday_calendar/constants.dart';

class AddBirthdayForm extends StatefulWidget {
  final DateTime dateOfDay;
  final StorageService storageService;

  AddBirthdayForm(
      {Key? key, required this.dateOfDay, required this.storageService})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AddBirthdayFormState();
  }
}

class AddBirthdayFormState extends State<AddBirthdayForm> {
  final _formKey = GlobalKey<FormState>();
  final _birthdayNameKey = GlobalKey<FormFieldState>();
  final _phoneNumberKey = GlobalKey<FormFieldState>();

  TextEditingController _birthdayPersonController = new TextEditingController();
  TextEditingController _phoneNumberController = new TextEditingController();
  PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'US');
  List<UserBirthday> birthdaysForDate = [];

  bool _isUniqueName(String name) {
    UserBirthday? birthday =
        birthdaysForDate.firstWhereOrNull((element) => element.name == name);
    return birthday == null;
  }

  @override
  void initState() {
    super.initState();
    _getBirthdaysForDate();
  }

  void _getBirthdaysForDate() async {
    birthdaysForDate =
        await widget.storageService.getBirthdaysForDate(widget.dateOfDay, true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: new Text(addBirthday),
      content: Form(
          key: _formKey,
          child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                new TextFormField(
                  autofocus: true,
                  controller: _birthdayPersonController,
                  decoration:
                      InputDecoration(hintText: "Enter the person's name"),
                  key: _birthdayNameKey,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a valid name';
                    }
                    if (!_isUniqueName(value)) {
                      return "A birthday with this name already exists";
                    }
                    return null;
                  },
                ),
                new InternationalPhoneNumberInput(
                  key: _phoneNumberKey,
                  onInputChanged: (PhoneNumber number) {
                    _phoneNumber = number;
                  },
                  onInputValidated: (bool value) {},
                  selectorConfig: SelectorConfig(
                    selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                  ),
                  ignoreBlank: false,
                  autoValidateMode: AutovalidateMode.disabled,
                  initialValue: _phoneNumber,
                  textFieldController: _phoneNumberController,
                  formatInput: false,
                  keyboardType: TextInputType.numberWithOptions(
                      signed: true, decimal: true),
                  inputBorder: OutlineInputBorder(),
                  onSaved: (PhoneNumber number) {
                    _phoneNumber = number;
                  },
                ),
              ])),
      actions: [
        TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            onPressed: () {
              if (_formKey.currentState != null &&
                  _formKey.currentState!.validate()) {
                _formKey.currentState!.save();

                UserBirthday userBirthday = new UserBirthday(
                    _birthdayPersonController.text,
                    widget.dateOfDay,
                    true,
                    _phoneNumber.parseNumber());
                BlocProvider.of<BirthdaysBloc>(context).add(new BirthdaysEvent(
                    eventName: BirthdayEvent.AddBirthday,
                    birthdays: birthdaysForDate,
                    birthday: userBirthday,
                    shouldShowAddBirthdayDialog: false));
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
            child: new Text("OK")),
        TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              _birthdayPersonController.clear();
              _phoneNumberController.clear();
              Navigator.pop(context);
            },
            child: new Text("BACK"))
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
