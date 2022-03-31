import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BirthdayManager {


  Color getColorBasedOnPosition(int index, String element) {
    if (element == "background") {
      return index % 2 == 0 ? Colors.indigoAccent : Colors.white24;
    }

    return index % 2 == 0 ? Colors.white : Colors.black;
  }

  void handleCallButtonPressed(String phoneNumber) async {
    String phoneUrl = 'tel://' + phoneNumber;
    if (await canLaunch(phoneUrl)) {
      launch(phoneUrl);
    }
  }

}