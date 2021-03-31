import 'package:flutter/material.dart';


class BirthdayPage extends StatelessWidget {

  final String dateOfDay;
  final List<String> birthdays;

  BirthdayPage({Key key, @required this.dateOfDay, @required this.birthdays}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Birthdays for $dateOfDay")),
      body: Center(
        child:
            Column(
              children: [
                Expanded(child:
                  ListView.builder(
                    itemCount: birthdays.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                          height: 50,
                          color: Colors.blueAccent,
                          child: Text("${birthdays[index]}")
                      );
                    },
                  ),
                ),
                TextButton(
                    onPressed: () {},
                    child: Text("Add Birthday")
                )
              ],
            )

      ),
    );
  }

}