import 'package:flutter/material.dart';
import 'package:flutter_mobilewise/utils/app_state.dart';

import '../../../../shared/model/framework_form.dart';
import '../../../../utils/common_constants.dart' as constants;
import '../../../../utils/hex_color.dart';
import '../../../../utils/util.dart';

class FormSeparatorFieldWidget extends StatefulWidget {
  const FormSeparatorFieldWidget({
    Key? key,
    required this.field,
  }) : super(key: key);

  final FrameworkFormField field;

  @override
  State<FormSeparatorFieldWidget> createState() =>
      _FormSeparatorFieldWidgetState();
}

class _FormSeparatorFieldWidgetState extends State<FormSeparatorFieldWidget> {
  @override
  Widget build(BuildContext context) {
    var style = widget.field.style;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        0.0,
        Util.instance.getTopMargin(widget.field.style),
        0.0,
        constants.smallPadding,
      ),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: style != null
            ? double.parse('${style!.size}')
            : constants.horizontalSeparatorHeight,
        color: (style == null || style!.color.isEmpty)
            ? HexColor(AppState.instance.themeModel.primaryColor)
            : HexColor(style.color),
      ),
    );
  }
}
