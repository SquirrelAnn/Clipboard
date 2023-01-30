import 'package:flutter/material.dart';

import 'darkcolors.dart';

class CustomDarkTheme {
  static ThemeData get darkTheme {
    return ThemeData(
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
          backgroundColor: MaterialStateProperty.all<Color>(DarkCustomColors.lightPurple),
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
        displayMedium: TextStyle(fontSize: 27.0, color: DarkCustomColors.darkestPurple),
        bodyLarge: TextStyle(fontSize: 20, color: DarkCustomColors.darkestPurple),
        bodyMedium: TextStyle(fontSize: 12.0, color: DarkCustomColors.darkestPurple),
        displaySmall: TextStyle(fontSize: 20, color: DarkCustomColors.lighterPurple),
        titleSmall: TextStyle(fontSize: 18.0, color: DarkCustomColors.darkestPurple),
        headlineMedium: TextStyle(fontSize: 17.0, color: DarkCustomColors.darkestPurple),
        titleMedium: const TextStyle(fontSize: 16.0),
        headlineSmall: TextStyle(fontSize: 25, color: DarkCustomColors.darkestPurple),
        titleLarge: TextStyle(fontSize: 30, color: DarkCustomColors.darkestPurple),
        displayLarge: TextStyle(fontSize: 20, color: DarkCustomColors.lighterPurple),
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
