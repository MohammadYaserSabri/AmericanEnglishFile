// ignore_for_file: file_names

import 'package:flutter/material.dart';

TextStyle welcomeTextStyle({double fontSize = 18, Color color = Colors.grey}) {
  return TextStyle(
    fontSize: fontSize,
    color: color,
    fontWeight: FontWeight.bold,
  );
}

TextStyle userNameTextStyle(
    {double fontSize = 24, Color color = Colors.deepPurple}) {
  return TextStyle(
    fontSize: fontSize,
    color: color,
    fontWeight: FontWeight.bold,
  );
}

TextStyle bannerTextStyle(
    {double fontSize = 24, Color color = Colors.deepPurple}) {
  return const TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
}
TextStyle defaultTextStyle(
    {double fontSize = 24, Color color = Colors.white}) {
  return TextStyle(
    fontSize: fontSize,
    color: color,
    fontWeight: FontWeight.bold,
  );
}