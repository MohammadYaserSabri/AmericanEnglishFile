import 'package:flutter/material.dart';
import 'package:flutter_application_caht/Presentation/Styles/TextStyles/CustomTextStyles.dart';

Widget customMaterialButton({
  required String text,
  required VoidCallback onPressed,
  Color backgroundColor = Colors.white,
  Color textColor = Colors.deepPurple,
  Color hoverColor = Colors.deepPurpleAccent,
  double elevation = 5.0,
  double minWidth = 200.0,
  double height = 42.0,
  BorderRadiusGeometry borderRadius = const BorderRadius.all(Radius.circular(30.0)),
}) {
  return Material(
    elevation: elevation,
    color: backgroundColor,
    borderRadius: borderRadius,
    child: MaterialButton(
      onPressed: onPressed,
      hoverColor: hoverColor,
      minWidth: minWidth,
      height: height,
      child: Text(
        text,
        style:defaultTextStyle(fontSize: 16, color: textColor)
      ),
    ),
  );
}
