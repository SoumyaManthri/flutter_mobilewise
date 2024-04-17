import 'package:flutter/material.dart';
import 'package:flutter_mobilewise/utils/app_state.dart';
import 'package:intl/intl.dart';

import '../../../../screens/forms/view_model/form_view_model.dart';
import '../../../../shared/model/framework_form.dart';
import '../../../../utils/common_constants.dart' as constants;
import '../../../../utils/util.dart';

class FormLabelValueFieldWidget extends StatefulWidget {
  const FormLabelValueFieldWidget({
    Key? key,
    required this.field,
    required this.viewModel,
    this.value,
  }) : super(key: key);

  final FrameworkFormField field;
  final FormViewModel viewModel;
  final String? value;

  @override
  State<FormLabelValueFieldWidget> createState() => _FormTextFieldWidgetState();
}

class _FormTextFieldWidgetState extends State<FormLabelValueFieldWidget> {

  String value = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getValue();
  }

  getValue(){
    value = widget.value ??
        widget.viewModel.dataListSelected?.dataMap?[widget.field.defaultValue]
            ?.value ??
        '';
    String? dateFormat = widget.field.additionalConfig.dateFormat ?? "dd-MM-yyyy";
    if (widget.field.widgetType == 'date' && value.isNotEmpty) {
      try {
        if (value.contains(",")) {
          List<String> dateRange = value.split(',');
          DateTime startDate = DateTime.parse(dateRange[0]);
          DateTime endDate = DateTime.parse(dateRange[1]);
          String startDateString = Util.instance.setDynamicDateFormat(startDate,dateFormat!);
          String endDateString = Util.instance.setDynamicDateFormat(endDate,dateFormat);
          value = '$startDateString - $endDateString';
        } else {
          DateTime dateTime = DateTime.parse(value);
          value = Util.instance.setDynamicDateFormat(dateTime,dateFormat!);
        }
      } catch (e) {
        value = widget.value ?? '';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: _view(),
    );
  }

  AlignmentGeometry getAlignment(String alignment) {
    switch (alignment.toLowerCase()) {
      case 'right':
        return Alignment.centerRight;
      case 'center':
        return Alignment.center;
      case 'left':
      default:
        return Alignment.centerLeft;
    }
  }

  _view() {

    return Padding(
      padding: const EdgeInsets.all(constants.mediumPadding),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
            child: Align(
                alignment: getAlignment('left'),
                child: Text('${widget.field.label}: ',
                    style: constants.smallGreyTextStyle))),
        SizedBox(width: 5.0,),
        Expanded(
            child: Align(
                alignment: getAlignment('left'),
                child: Text(
                  value,
                  style: AppState.instance.themeModel.themeName.contains("Dark")?constants.smallGreyTextStyle: constants.normalBlackTextStyle,
                )))
      ]),
    );
  }
}
