import 'package:flutter/material.dart';

class GlobalVarriable{


  static String  productApi="https://fakestoreapi.com/products";



 static TextStyle customTextStyle({
    required Color color ,
    required double fontSize,
    required FontWeight fontWeight ,

  }) {
    return TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,

    );
  }
}