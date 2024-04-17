import 'package:flutter/material.dart';

import '../../../../screens/forms/view_model/form_view_model.dart';
import '../../../../shared/model/framework_form.dart';
import '../../../../utils/app_state.dart';
import '../../../../utils/common_constants.dart' as constants;
import '../../../../utils/common_constants.dart';
import '../../../../utils/hex_color.dart';
import '../../../../utils/util.dart';

class FormDateRangeWidget extends StatefulWidget {
  const FormDateRangeWidget({
    Key? key,
    required this.field,
    required this.viewModel,
  }) : super(key: key);

  final FrameworkFormField field;
  final FormViewModel viewModel;

  @override
  State<FormDateRangeWidget> createState() => _FormDateRangeWidgetState();
}

class _FormDateRangeWidgetState extends State<FormDateRangeWidget> {
  TextEditingController textEditingController = TextEditingController();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  DateTime todayDate = DateTime.now();
  String initValue = '';
  FocusNode myfocus = FocusNode();
  String? errorMessage;
  static const String OUTLINED_TYPE = 'outlined';
  static const String FILLED_TYPE = 'filled';
  DateTime rangeStartDate = DateTime.now();
  DateTime rangeEndDate = DateTime.now();
  int maxDays = 0;
  int minDays = 0;

  @override
  void initState() {
    super.initState();
    if (widget.field.isEditable &&
        AppState.instance.formTempMap.containsKey(widget.field.key)) {
      String value = AppState.instance.formTempMap[widget.field.key];
      List<String> dateRange = value.split(',');
      startDate = DateTime.parse(dateRange[0]);
      endDate = DateTime.parse(dateRange[1]);
      String startDateString = Util.instance.getDisplayDate(startDate);
      String endDateString = Util.instance.getDisplayDate(endDate);
      textEditingController.text = '$startDateString - $endDateString';
      initValue = '$startDateString - $endDateString';
    } else if (widget.viewModel.clickedSubmissionValuesMap
        .containsKey(widget.field.key)) {
      String value =
          widget.viewModel.clickedSubmissionValuesMap[widget.field.key];
      List<String> dateRange = value.split(',');
      startDate = DateTime.parse(dateRange[0]);
      endDate = DateTime.parse(dateRange[1]);
      String startDateString = Util.instance.getDisplayDate(startDate);
      String endDateString = Util.instance.getDisplayDate(endDate);
      textEditingController.text = '$startDateString - $endDateString';
      initValue = '$startDateString - $endDateString';
    }

    if(widget.field.validations.isNotEmpty){
      for(int i=0;i<widget.field.validations.length;i++) {
        if(widget.field.validations[i].validationKey =='sDate'){
          rangeStartDate = DateTime.parse(widget.field.validations[i].validationValue!);
        }else{
          rangeEndDate = DateTime.parse(widget.field.validations[i].validationValue!);
        }
      }
    }

    if(widget.field.additionalConfig.minDateRange != null){
      minDays = widget.field.additionalConfig.minDateRange!;
    }

    if(widget.field.additionalConfig.maxDateRange != null){
      maxDays = widget.field.additionalConfig.maxDateRange!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.field.isEditable
        ? Padding(
        padding: EdgeInsets.fromLTRB(
            0.0,
            Util.instance.getTopMargin(widget.field.style),
            0.0,
            constants.mediumPadding),
        child: textField())
        : initValue.isNotEmpty
        ? Padding(
      padding: const EdgeInsets.fromLTRB(
          constants.mediumPadding,
          constants.smallPadding,
          constants.mediumPadding,
          constants.smallPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.field.label,
            style: constants.smallGreyTextStyle,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0.0,
                constants.smallPadding, 0.0, constants.smallPadding),
            child: Text(
              initValue,
              style: constants.normalBlackTextStyle,
            ),
          ),
        ],
      ),
    )
        : const SizedBox();
  }

  TextFormField textField() {
    return TextFormField(
      readOnly: false,
      focusNode: myfocus,
      autovalidateMode: AutovalidateMode.always,
      enabled: widget.field.isEditable,
      showCursor: false,
      controller: textEditingController,
      keyboardType: TextInputType.none,
      enableInteractiveSelection: false,
      enableSuggestions: false,
      onTap: () {
        myfocus.unfocus();
        _selectDateRange(context);
      },
      autocorrect: false,
      decoration: decoration(widget.field.matUiType),
      validator: (value) {
        return validation(value);
      },
      style:  TextStyle(color:HexColor(AppState.instance.themeModel.textColor)),
    );
  }

  InputDecoration decoration(String type) {
    switch (type) {
      case FILLED_TYPE:
        return borderFilled();

      case OUTLINED_TYPE:
      default:
        return borderOutlined();
    }
  }

  InputDecoration borderOutlined() {
    return InputDecoration(
        label: constants.mandatoryField(widget.field),
        // labelText: widget.field.label,
        hintText: widget.field.hint,
        helperText: errorMessage,
        fillColor: HexColor(AppState.instance.themeModel.backgroundColor),
        filled: true,
        border: OutlineInputBorder(
          borderSide: BorderSide(
              width: 2,
              color: HexColor(AppState.instance.themeModel.primaryColor)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              width: 2,
              color: HexColor(AppState.instance.themeModel.primaryColor)),
        ),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: HexColor(AppState.instance.themeModel.textColor))),
        errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(width: 2, color: Colors.red)),
        floatingLabelStyle: TextStyle(
            color: HexColor(AppState.instance.themeModel.primaryColor)),
        labelStyle: const TextStyle(color: Color(constants.hintTextColor)),
        errorStyle: const TextStyle(color: Colors.red),
        suffixIcon: sufficIcon());
  }

  InputDecoration borderFilled() {
    FrameworkFormStyle? style = widget.field.style;
    return InputDecoration(
        labelText: widget.field.label,
        hintText: widget.field.hint,
        helperText: errorMessage,
        hintStyle: const TextStyle(color: Color(constants.hintTextColor)),
        fillColor: HexColor(AppState.instance.themeModel.backgroundColor),
        filled: true,
        border: UnderlineInputBorder(
          borderSide: BorderSide(
              width: 2,
              color: HexColor(AppState.instance.themeModel.primaryColor)),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
              width: 2,
              color: HexColor(AppState.instance.themeModel.primaryColor)),
        ),
        enabledBorder:  UnderlineInputBorder(
            borderSide: BorderSide(color: HexColor(AppState.instance.themeModel.textColor))),
        errorBorder: const UnderlineInputBorder(
            borderSide: BorderSide(width: 2, color: Colors.red)),
        floatingLabelStyle: TextStyle(
            color: HexColor(AppState.instance.themeModel.primaryColor)),
        labelStyle: style != null
            ? applyStyleV2(
            bold: style.bold,
            underline: style.underline,
            italics: style.italics,
            color: style.color,
            size: style.size)
            : null,
        errorStyle: const TextStyle(color: Colors.red),
        suffixIcon: sufficIcon());
  }

  sufficIcon() {
    return  Icon(Icons.calendar_month_outlined, color: HexColor(AppState.instance.themeModel.textColor));
  }

  String? validation(String? value) {
    if (widget.viewModel.errorWidgetMap.containsKey(widget.field.key)) {
      String? errorMsg = widget.viewModel.errorWidgetMap[widget.field.key];
      if (textEditingController.text.isNotEmpty) {
        widget.viewModel.errorWidgetMap.remove(widget.field.key);
        return null;
      }
      widget.viewModel.scrollToFirstValidationErrorWidget(context);
      errorMessage = errorMsg;
      return errorMsg;
    }
    return null;
  }

  String startDateString = '';
  String endDateString = '';

  Future<void> _selectDateRange(BuildContext context) async {
    datePicker(rangeStartDate, rangeStartDate,rangeEndDate,false, constants.selectStartDate);
  }

  datePicker(DateTime initialDate, DateTime firstDate,
      DateTime lastDate, bool isEndDate, String helpText)async{
    final DateTime? dateTime = await showDatePicker(
      context: context,
      helpText: helpText,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData(
            textTheme: const TextTheme(overline: TextStyle(fontSize: 16.0)),
          ),
          child: child!,
        );
      },
    );
    if(isEndDate){
      if (dateTime != null) {
        if(dateTime.isAfter(startDate) || dateTime.isAtSameMomentAs(startDate)) {
          Duration difference = dateTime.difference(startDate);
          int dayDifferentCount =difference.inDays + 1;
          if( dayDifferentCount <= maxDays && dayDifferentCount >= minDays){
            setState(() {
              endDate = dateTime;
              endDateString = Util.instance.setDynamicDateFormat(endDate, widget.field.additionalConfig.dateFormat!);
              textEditingController.text = '$startDateString - $endDateString';
              AppState.instance
                  .addToFormTempMap(widget.field.key, '$startDate,$endDate');
            });
          }else{
            AppState.instance.toastMessage("Maximum days need $maxDays and  Minimum days need $minDays");
            datePicker(startDate, startDate,rangeEndDate,true, constants.selectEndDate);
          }
        }
      }
    }else{
      startDate = dateTime!;
      startDateString = Util.instance.setDynamicDateFormat(startDate, widget.field.additionalConfig.dateFormat!);
      datePicker(startDate, startDate,rangeEndDate,true, constants.selectEndDate);
      AppState.instance.toastMessage(constants.selectEndDate);

    }

  }
}
