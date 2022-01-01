import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import 'package:birthday_calendar/constants.dart';

class AddBirthdayForm extends StatefulWidget {
  const AddBirthdayForm({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AddBirthdayFormState();
  }
}

class AddBirthdayFormState extends State<AddBirthdayForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _birthdayPersonController = new TextEditingController();
  TextEditingController _phoneNumberController = new TextEditingController();
  PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'US');

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
                    decoration: InputDecoration(hintText: "Enter the person's name"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a valid name';
                      }
                      return null;
                    },
                  ),
                  new InternationalPhoneNumberInput(
                    onInputChanged: (PhoneNumber number) {
                      _phoneNumber = number;
                    },
                    onInputValidated: (bool value) {

                    },
                    selectorConfig: SelectorConfig(
                      selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                    ),
                    ignoreBlank: false,
                    autoValidateMode: AutovalidateMode.disabled,
                    selectorTextStyle: TextStyle(color: Colors.black),
                    initialValue: _phoneNumber,
                    textFieldController: _phoneNumberController,
                    formatInput: false,
                    keyboardType:
                    TextInputType.numberWithOptions(signed: true, decimal: true),
                    inputBorder: OutlineInputBorder(),
                    onSaved: (PhoneNumber number) {
                      _phoneNumber = number;
                    },
                  ),
                ]
            )
        ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(primary: Colors.green),
          onPressed: () {
            if (_formKey.currentState != null && _formKey.currentState!.validate()) {
              _formKey.currentState!.save();
            }
            _birthdayPersonController.text = "";
            _phoneNumberController.text = "";
          },
          child: new Text("OK")
        ),
        TextButton(
          style: TextButton.styleFrom(primary: Colors.red),
          onPressed: () {
            _birthdayPersonController.text = "";
            _phoneNumberController.text = "";
            Navigator.pop(context);
          },
          child: new Text("BACK")
        )
      ],
    );
  }

}

