import 'package:flutter/material.dart';

class GlobalVarriable{






 static TextStyle customTextStyle({
    required Color color ,
    required double fontSize,
    required FontWeight fontWeight ,

  }) {
    return TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontFamily: "Inter",

    );
  }
}