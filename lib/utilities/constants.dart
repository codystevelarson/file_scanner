import 'package:flutter/material.dart';

const kColorRoseLt = Color(0xFFFFE4E1);
const kColorGrey = Color(0xFF616163);
const kColorGreyLt = Colors.grey;
const kColorTeal = Color(0xFF44FFD2);
const kColorBlueLt = Colors.lightBlueAccent;
const kColorBlack = Colors.black;
const kColorWhite = Colors.white;

final ThemeData lightTheme = ThemeData(
  primaryColor: kColorBlueLt,
  primaryColorDark: kColorBlack,
  secondaryHeaderColor: kColorTeal,
  backgroundColor: kColorWhite,
  textTheme: const TextTheme(
    headline1: TextStyle(color: kColorBlack),
    headline2: TextStyle(color: kColorBlack),
    headline3: TextStyle(color: kColorBlack),
    bodyText1: TextStyle(color: kColorBlack),
    bodyText2: TextStyle(color: kColorBlack),
  ),
  colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.red),
);

final ThemeData darkTheme = ThemeData(
  primaryColor: kColorTeal,
  primaryColorDark: kColorWhite,
  secondaryHeaderColor: kColorBlueLt,
  backgroundColor: kColorBlack,
  textTheme: const TextTheme(
    headline1: TextStyle(color: kColorWhite),
    headline2: TextStyle(color: kColorWhite),
    headline3: TextStyle(color: kColorWhite),
    bodyText1: TextStyle(color: kColorWhite),
    bodyText2: TextStyle(color: kColorWhite),
  ),
  colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.red),
);
