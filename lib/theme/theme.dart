import 'package:flutter/material.dart';

class MyAppTheme
{
  static MaterialColor PRIMARY_COLOR = Colors.red;
  static Color SECONDARY_COLOR = Colors.white;



  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: PRIMARY_COLOR,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(PRIMARY_COLOR),
        foregroundColor: WidgetStateProperty.all<Color>(SECONDARY_COLOR),
      ),

    ),
    appBarTheme: AppBarTheme(
      backgroundColor: PRIMARY_COLOR,
      foregroundColor: SECONDARY_COLOR,
    ),

    textTheme: TextTheme(
      headlineMedium: TextStyle(
        color: Colors.black,
        fontSize: 25,
      ),
      labelSmall: TextStyle(
        color: Colors.red,
        fontSize: 10,
      ),
    ),  
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      filled: true,
      fillColor: Colors.red.shade50,
    ),  
  );
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: PRIMARY_COLOR,

  );
  MyAppTheme._();   //static to set propery. we dont want to make object
}