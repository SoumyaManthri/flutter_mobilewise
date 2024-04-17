import 'package:flutter/material.dart';

import '../shared/model/form_model.dart';
import 'app_state.dart';
import 'common_constants.dart';
import 'hex_color.dart';

class Styling {
  static applyStyle(WidgetConfigStyle? style) {
    return TextStyle(
      fontWeight: (style != null && (style.fontWeight ?? 'normal') != 'normal')
          ? FontWeight.bold
          : FontWeight.normal,
      decoration: (style != null && (style.textDecoration ?? 'none') != 'none')
          ? TextDecoration.underline
          : TextDecoration.none,
      decorationColor: (style != null && style.color!.isNotEmpty)
          ? HexColor(style.color!)
          : HexColor(AppState.instance.themeModel.textColor),
      fontSize: double.parse(style!.fontSize != null ? style.fontSize!.replaceAll('px', "") : '16'),
      fontStyle: ((style.fontStyle ?? 'normal') != 'normal')
          ? FontStyle.italic
          : FontStyle.normal,
      color: (style.color!.isNotEmpty)
          ? HexColor(style.color!)
          : HexColor(AppState.instance.themeModel.textColor),
    );
  }

  static TextStyle applyStyleV2(
      {bool bold = false,
        bool underline = false,
        bool italics = false,
        String? color,
        int size = 16}) {
    color = color != null && color.isNotEmpty ? color : getColor();
    return TextStyle(
        fontWeight: bold == true ? FontWeight.bold : FontWeight.normal,
        decoration:
        underline == true ? TextDecoration.underline : TextDecoration.none,
        decorationColor: HexColor(color!),
        fontSize: double.parse('$size'),
        fontStyle: italics ? FontStyle.italic : FontStyle.normal,
        color: HexColor(color));
  }

  static getColor() {
    if (AppState.instance.themeModel.textColor.isNotEmpty) {
      return AppState.instance.themeModel.textColor;
    } else {
      return labelTextColor;
    }
    ;
  }
}