import 'package:flutter/material.dart';
import 'package:frontend/ui/core/tongi_colors.dart';

class TongiStyles {
  static const TextStyle textBody = TextStyle(
    fontSize: 14,
    fontFamily: "Poppins",
    color: TongiColors.darkGray,
  );

  static const TextStyle textTitle = TextStyle(
    fontSize: 18,
    fontFamily: "Poppins",
    fontWeight: FontWeight.w500,
  );

  static const TextStyle textLabel = TextStyle(
    fontSize: 12,
    fontFamily: "Poppins",
    fontWeight: FontWeight.w500,
  );

  static const TextStyle textInput = TextStyle(
    fontSize: 22,
    color: TongiColors.textFill,
    fontFamily: "NotoSans",
  );

  static const TextStyle textOutput = TextStyle(
    fontSize: 22,
    color: TongiColors.textFill,
    fontFamily: "NotoSans",
  );

  static const TextStyle textAudInput = TextStyle(
    fontSize: 18,
    color: TongiColors.textFill,
    fontFamily: "NotoSans",
  );

  static const TextStyle textAudOutput = TextStyle(
    fontSize: 18,
    color: TongiColors.textFill,
    fontFamily: "NotoSans",
  );

  static const TextStyle textFieldMainLabel = TextStyle(
    color: TongiColors.primary,
    fontFamily: "Poppins",
    fontWeight: FontWeight.w500,
    fontSize: 14,
  );

  static const TextStyle textFieldGrayLabel = TextStyle(
    color: TongiColors.darkGray,
    fontFamily: "Poppins",
    fontWeight: FontWeight.w500,
    fontSize: 14,
  );

  static const OutlineInputBorder enabledBorder = OutlineInputBorder(
    borderSide: BorderSide(color: TongiColors.border, width: 1),
    borderRadius: BorderRadius.all(Radius.circular(10)),
  );

  static const OutlineInputBorder focusedBorder = OutlineInputBorder(
    borderSide: BorderSide(color: TongiColors.onFocus, width: 1),
    borderRadius: BorderRadius.all(Radius.circular(10)),
  );
}
