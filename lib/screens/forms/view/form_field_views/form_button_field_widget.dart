import 'package:flutter/material.dart';

import '../../../../shared/model/framework_form.dart';
import '../../../../screens/forms/view_model/form_view_model.dart';
import '../../../../utils/app_state.dart';
import '../../../../utils/common_constants.dart' as constants;
import '../../../../utils/hex_color.dart';
import '../../../../utils/util.dart';

class FormButtonFieldWidget extends StatefulWidget {
  const FormButtonFieldWidget({
    Key? key,
    required this.field,
    required this.viewModel,
    required this.label

  }) : super(key: key);

  final FrameworkFormField field;
  final FormViewModel viewModel;
  final String label;

  @override
  State<FormButtonFieldWidget> createState() => _FormButtonFieldWidgetState();
}

class _FormButtonFieldWidgetState extends State<FormButtonFieldWidget> {
  late Color bgColor;

  @override
  Widget build(BuildContext context) {
    if (widget.field.style != null && widget.field.style!.bgColor.isNotEmpty) {
      bgColor = HexColor(widget.field.style!.bgColor);
    } else {
      bgColor = HexColor(AppState.instance.themeModel.primaryColor);
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(
          0.0,
          Util.instance.getTopMargin(widget.field.style),
          0.0,
          constants.mediumPadding),
      child: SizedBox(
        height: constants.buttonHeight,
        width: MediaQuery.of(context).size.width,
        child: ElevatedButton(
          onPressed: () async {
            /// Form button clicked
            widget.viewModel.fieldButtonPressed(widget.field, context, false,widget.label);
          },
          style: constants.buttonFilledStyle(backgroundColor: bgColor),
          child: Text(
            widget.label != null && widget.label.isNotEmpty ? widget.label :widget.field.label,
            style: constants.applyStyle(widget.field.style),
          ),
        ),
      ),
    );
  }
}
