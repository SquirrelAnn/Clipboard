import 'package:clipboard/models/category.dart';
import 'package:flutter/material.dart';

import '../theme/dark_theme.dart';
import 'package:uuid/uuid.dart';

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
        style: CustomDarkTheme.darkTheme.textTheme.bodyMedium,
      ),
      content: Text(
        "Delete category?",
        style: CustomDarkTheme.darkTheme.textTheme.bodyMedium,
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
    TextEditingController _controllerTitle = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // _controller.text = "";
        // _controller.selection = TextSelection(baseOffset: 0, extentOffset: _controller.text.length);
        return AlertDialog(
          title: Text(
            title,
            style: CustomDarkTheme.darkTheme.textTheme.bodyMedium,
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
                // title
                keyboardType: TextInputType.multiline,
                autofocus: true,
                controller: _controllerTitle,
                style: CustomDarkTheme.darkTheme.textTheme.bodyMedium,
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
                Navigator.pop(context, [_controllerTitle.text.toString()]);
              },
            )
          ],
        );
      },
    ).then((val) {
      List<String> list = val;
      String joined = list.join('\n');
      setValue(joined);
    });
  }

  static showNumTxtDlgSnippet(String title, Function setValue, BuildContext context) {
    TextEditingController _controllerTitle = TextEditingController();
    TextEditingController _controllerText = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // _controller.text = "";
        // _controller.selection = TextSelection(baseOffset: 0, extentOffset: _controller.text.length);
        return AlertDialog(
          title: Text(
            title,
            style: CustomDarkTheme.darkTheme.textTheme.bodyMedium,
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              Text("Title:"),
              TextField(
                // title
                decoration: InputDecoration(
                  hintText: 'Title',
                ),
                keyboardType: TextInputType.multiline,
                autofocus: true,
                controller: _controllerTitle,
                style: CustomDarkTheme.darkTheme.textTheme.bodyMedium,
              ),
              Text("Value:"),
              TextField(
                // text
                decoration: InputDecoration(
                  hintText: 'Value',
                ),
                keyboardType: TextInputType.multiline,
                autofocus: true,
                controller: _controllerText,
                style: CustomDarkTheme.darkTheme.textTheme.bodyMedium,
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
                Navigator.pop(context, [_controllerTitle.text, _controllerText.text]);
              },
            )
          ],
        );
      },
    ).then((val) {
      //expect a snippet in return
      List<String> list = val;
      var uuid = const Uuid();
      var v1 = uuid.v1();
      Snippet snippet = Snippet(id: v1, snippetText: list[1], snippetTitle: list[0]);
      setValue(snippet);
    });
  }
}
