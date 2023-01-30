import 'package:flutter/material.dart';

import '../theme/dark_theme.dart';

class AlertWidgets {
  static showDecisionDialog(BuildContext context, int index, Function function) {
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: const Text("OK"),
      onPressed: () async {
        function(index);
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(
        "Warning",
        style: CustomDarkTheme.darkTheme.textTheme.bodyText2,
      ),
      content: Text(
        "Delete category?",
        style: CustomDarkTheme.darkTheme.textTheme.bodyText2,
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static showNumTxtDlg(String title, Function setValue, BuildContext context) {
    TextEditingController _controller = TextEditingController();
    String text = "";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // _controller.text = "";
        // _controller.selection = TextSelection(baseOffset: 0, extentOffset: _controller.text.length);
        return AlertDialog(
          title: Text(
            title,
            style: CustomDarkTheme.darkTheme.textTheme.bodyText2,
          ),
          content: Column(
            children: [
              // Expanded(
              //   child: Container(
              //     padding: EdgeInsets.all(4),
              //     decoration: BoxDecoration(
              //         borderRadius: BorderRadius.all(Radius.circular(10)),
              //         border: Border.all(color: CustomDarkTheme.darkTheme.canvasColor),
              //         color: CustomDarkTheme.darkTheme.canvasColor),
              //     child: Padding(
              //       padding: EdgeInsets.all(4),
              //       child: TextField(
              //         controller: _controller,
              //         keyboardType: TextInputType.multiline,
              //         maxLines: null,
              //         onChanged: (value) {
              //           text = value;
              //         },
              //       ),
              //     ),
              //   ),
              // ),
              //Row(
              //  children: [
              //Expanded(
              // child:
              TextField(
                keyboardType: TextInputType.multiline,
                autofocus: true,
                controller: _controller,
                style: CustomDarkTheme.darkTheme.textTheme.bodyText2,
              ),
              //),
              //  ],
              //)
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.pop(context, _controller.text);
              },
            )
          ],
        );
      },
    ).then((val) {
      setValue(val);
    });
  }
}
