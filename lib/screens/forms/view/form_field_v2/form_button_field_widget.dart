import 'package:flutter/material.dart';

import '../../../../screens/forms/view_model/form_view_model.dart';
import '../../../../shared/model/framework_form.dart';
import '../../../../utils/app_state.dart';
import '../../../../utils/common_constants.dart' as constants;
import '../../../../utils/hex_color.dart';
import '../../../../utils/util.dart';

class FormButtonFieldWidget extends StatefulWidget {
  const FormButtonFieldWidget({
    Key? key,
    required this.field,
    required this.viewModel,
  }) : super(key: key);

  final FrameworkFormField field;
  final FormViewModel viewModel;

  @override
  State<FormButtonFieldWidget> createState() => _FormButtonFieldWidgetState();
}

class _FormButtonFieldWidgetState extends State<FormButtonFieldWidget> {
  FrameworkFormStyle? style;

  static const String OUTLINED_TYPE = 'outlined';
  static const String FILLED_TYPE = 'filled';

  @override
  Widget build(BuildContext context) {
    style = widget.field.style;

    return Padding(
      padding: EdgeInsets.only(
          top: Util.instance.getTopMargin(widget.field.style),
          bottom: constants.mediumPadding),
      child: SizedBox(
        height: constants.buttonHeight,
        width: MediaQuery.of(context).size.width,
        child: getButton(widget.field.matUiType),
      ),
    );
  }

  getButton(String type) {
    Color? bgColor;
    String label =
        widget.field.valuesApi.isPreview ? 'Preview' : widget.field.label;

    if (widget.field.style != null && widget.field.style!.bgColor.isNotEmpty) {
      bgColor = HexColor(widget.field.style!.bgColor);
    }

    switch (type) {
      case OUTLINED_TYPE:
        return outlinedButton(bgColor: bgColor, label: label);

      case FILLED_TYPE:
      default:
        return filledButton(bgColor: bgColor, label: label);
    }
  }

  filledButton({Color? bgColor, required String label}) {
    return FilledButton(
      onPressed: () async {
        widget.viewModel.fieldButtonPressed(
            widget.field, context, true, widget.field.label);
      },
      style: constants.buttonFilledStyle(
          backgroundColor:
              bgColor ?? HexColor(AppState.instance.themeModel.primaryColor)),
      child: Text(
        label,
        style: textStyle(AppState.instance.themeModel.secondaryColor),
      ),
    );
  }

  outlinedButton({Color? bgColor, required String label}) {
    return OutlinedButton(
      onPressed: () async {
        widget.viewModel.fieldButtonPressed(
            widget.field, context, true, widget.field.label);
      },
      style: constants.buttonOutlineStyle(
          backgroundColor:
              bgColor ?? HexColor(AppState.instance.themeModel.primaryColor)),
      child: Text(
        label,
        style: textStyle(AppState.instance.themeModel.primaryColor),
      ),
    );
  }

  textStyle(String defaultColor) {
    return constants.applyStyleV2(
        bold: style!.bold,
        underline: style!.underline,
        italics: style!.italics,
        color: (style!.color.isEmpty) ? defaultColor : style!.color,
        size: style!.size);
  }
}
