import 'package:flutter/material.dart';

import 'darkcolors.dart';

class CustomLightTheme {
  static ThemeData get lightTheme {
    //1
    return ThemeData(
      //2
      backgroundColor: DarkCustomColors.lightPurple,
      primaryColor: DarkCustomColors.purple,
      unselectedWidgetColor: DarkCustomColors.darkPurple,
      scaffoldBackgroundColor: DarkCustomColors.white,
      fontFamily: 'Karla',
      hoverColor: DarkCustomColors.transparent,
      canvasColor: DarkCustomColors.lighterPurpleTransp,

      focusColor: DarkCustomColors.flash,

      colorScheme: ColorScheme(
        primary: DarkCustomColors.lightPurple,
        onPrimary: DarkCustomColors.darkestPurple,
        background: DarkCustomColors.lighterPurple,
        onBackground: DarkCustomColors.purple,
        inversePrimary: DarkCustomColors.darkPurple,
        secondary: DarkCustomColors.midpurple,
        onSecondary: DarkCustomColors.white,
        errorContainer: DarkCustomColors.green,
        error: DarkCustomColors.red,
        onError: DarkCustomColors.white,
        surface: DarkCustomColors.white,
        onSurface: DarkCustomColors.darkGray,
        inverseSurface: DarkCustomColors.black,
        brightness: Brightness.light,
      ),
      iconTheme: IconThemeData(color: DarkCustomColors.lightPurple),
      buttonTheme: ButtonThemeData(
          // 4
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
          buttonColor: DarkCustomColors.lightPurple),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(DarkCustomColors.darkestPurple),
          backgroundColor: MaterialStateProperty.all<Color>(DarkCustomColors.lightPurple),
          overlayColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.hovered)) return DarkCustomColors.purple.withOpacity(0.04);
              if (states.contains(MaterialState.focused) || states.contains(MaterialState.pressed)) {
                return DarkCustomColors.purple.withOpacity(0.12);
              }
              return DarkCustomColors.purple; // Defer to the widget's default.
            },
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          textStyle:
              MaterialStateProperty.all<TextStyle>(TextStyle(fontSize: 12.0, color: DarkCustomColors.darkestPurple)),
          foregroundColor: MaterialStateProperty.all<Color>(DarkCustomColors.darkestPurple),
          backgroundColor: MaterialStateProperty.all<Color>(DarkCustomColors.btnHighlighted),
          overlayColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.hovered)) return DarkCustomColors.purple.withOpacity(0.04);
              if (states.contains(MaterialState.focused) || states.contains(MaterialState.pressed)) {
                return DarkCustomColors.purple;
              }
              return DarkCustomColors.purple; // Defer to the widget's default.
            },
          ),
        ),
      ),
      dialogTheme: DialogTheme(backgroundColor: DarkCustomColors.darkPurple),
      textTheme: TextTheme(
        headline2: TextStyle(fontSize: 27.0, color: DarkCustomColors.darkestPurple),
        bodyText1: TextStyle(fontSize: 20, color: DarkCustomColors.darkestPurple),
        bodyText2: TextStyle(fontSize: 12.0, color: DarkCustomColors.darkestPurple),
        headline3: TextStyle(fontSize: 20, color: DarkCustomColors.lighterPurple),
        subtitle2: TextStyle(fontSize: 18.0, color: DarkCustomColors.darkestPurple),
        headline4: TextStyle(fontSize: 17.0, color: DarkCustomColors.darkestPurple),
        subtitle1: const TextStyle(fontSize: 16.0),
        headline5: TextStyle(fontSize: 25, color: DarkCustomColors.darkestPurple),
        headline6: TextStyle(fontSize: 30, color: DarkCustomColors.darkestPurple),
        headline1: TextStyle(fontSize: 20, color: DarkCustomColors.lighterPurple),
      ),
      tabBarTheme: TabBarTheme(
        labelStyle: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: DarkCustomColors.lighterPurple),
        unselectedLabelStyle: TextStyle(fontSize: 18.0, color: DarkCustomColors.darkestPurple),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateColor.resolveWith(
          (states) {
            if (states.contains(MaterialState.selected)) {
              return DarkCustomColors.midpurple; // the color when checkbox is selected;
            }
            return DarkCustomColors.midpurple; //the color when checkbox is unselected;
          },
        ),
      ),
    );
  }
}
