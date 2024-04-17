import 'package:flutter/material.dart';

import '../../../../screens/forms/view_model/form_view_model.dart';
import '../../../../shared/model/form_model.dart';
import '../../../../utils/app_state.dart';
import '../../../../utils/common_constants.dart' as constants;
import '../../../../utils/hex_color.dart';
import '../../../../utils/styling.dart';
import '../../../../utils/util.dart';

class FormDatePickerWidget extends StatefulWidget {
  const FormDatePickerWidget(
      {Key? key, required this.viewModel, required this.widgetInfo})
      : super(key: key);

  final FormViewModel viewModel;
  final WidgetInfo widgetInfo;

  @override
  State<FormDatePickerWidget> createState() => _FormDatePickerWidgetState();
}

class _FormDatePickerWidgetState extends State<FormDatePickerWidget> {
  static const String outlinedType = 'outlined';
  static const String filledType = 'filled';

  final TextEditingController _textEditingController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  DateTime rangeStartDate = DateTime.now();
  DateTime rangeEndDate = DateTime.now();

  FocusNode focus = FocusNode();

  String? errorMessage;

  @override
  void initState() {
    super.initState();
    if (AppState.instance.formTempMap.containsKey(widget.widgetInfo.widgetId)) {

      var date = AppState.instance.formTempMap[widget.widgetInfo.widgetId];

      String dateString = date.toString();
      String? dateFormat = widget.widgetInfo.widgetConfig.additionalConfig!.dateFormat ?? "dd-MM-yyyy";

      String convertedDate;
      if (dateString.contains(',')) {
        List<String> dateRange = dateString.split(',');
        DateTime start = DateTime.parse(dateRange[0]);
        DateTime end = DateTime.parse(dateRange[1]);
        String startDate = Util.instance.setDynamicDateFormat(start, dateFormat);
        String endDate = Util.instance.setDynamicDateFormat(end, dateFormat);
        convertedDate = '$startDate - $endDate';
      } else {
        _selectedDate = date;
        convertedDate = Util.instance.setDynamicDateFormat(_selectedDate, dateFormat);
      }
      _textEditingController.text = convertedDate;
    } else if (widget.viewModel.clickedSubmissionValuesMap
        .containsKey(widget.widgetInfo.widgetId)) {
      int ts = int.parse(widget
          .viewModel.clickedSubmissionValuesMap[widget.widgetInfo.widgetId]);
      _selectedDate = DateTime.fromMillisecondsSinceEpoch(ts);
      String convertedDate = Util.instance.getDisplayDate(_selectedDate);
      _textEditingController.text = convertedDate;
    }

    widget.viewModel.datePickerFields[widget.widgetInfo.widgetId] =
        widget.widgetInfo;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.fromLTRB(
            0.0,
            Util.instance.getTopMarginFromWidgetInfo(
                widget.widgetInfo.widgetConfig.style),
            0.0,
            constants.mediumPadding),
        child: textField());
  }

  TextFormField textField() {
    return TextFormField(
      readOnly: false,
      focusNode: focus,
      autovalidateMode: AutovalidateMode.always,
      showCursor: false,
      controller: _textEditingController,
      keyboardType: TextInputType.none,
      enableInteractiveSelection: false,
      enableSuggestions: false,
      onTap: () {
        focus.unfocus();
        _selectDate(context, false);
      },
      autocorrect: false,
      decoration: decoration(widget.widgetInfo.widgetConfig.matUiType),
      validator: (value) {
        return validation(value);
      },
      style: TextStyle(color: HexColor(AppState.instance.themeModel.textColor)),
    );
  }

  InputDecoration decoration(String? type) {
    switch (type) {
      case outlinedType:
        return borderOutlined();

      case filledType:
      default:
        return borderFilled();
    }
  }

  InputDecoration borderOutlined() {
    return InputDecoration(
        label: constants.mandatoryFieldV2(widget.widgetInfo),
        // labelText: widget.field.label,
        hintText: widget.widgetInfo.widgetConfig.placeholderText,
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
            borderSide: BorderSide(
                color: HexColor(AppState.instance.themeModel.textColor))),
        errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(width: 2, color: Colors.red)),
        floatingLabelStyle: TextStyle(
            color: HexColor(AppState.instance.themeModel.primaryColor)),
        labelStyle: const TextStyle(color: Color(constants.hintTextColor)),
        errorStyle: const TextStyle(color: Colors.red),
        suffixIcon: suffixIcon());
  }

  InputDecoration borderFilled() {
    WidgetConfigStyle style = widget.widgetInfo.widgetConfig.style;
    return InputDecoration(
        label: constants.mandatoryFieldV2(widget.widgetInfo),
        hintText: widget.widgetInfo.widgetConfig.placeholderText,
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
        enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
                color: HexColor(AppState.instance.themeModel.textColor))),
        errorBorder: const UnderlineInputBorder(
            borderSide: BorderSide(width: 2, color: Colors.red)),
        floatingLabelStyle: TextStyle(
            color: HexColor(AppState.instance.themeModel.primaryColor)),
        labelStyle: style != null
            ? Styling.applyStyleV2(
                bold: (style.fontWeight ?? 'normal') != 'normal',
                underline: (style.textDecoration ?? 'none') != 'none',
                italics: (style.fontStyle ?? 'normal') != 'normal',
                color: style.color,
                size: int.parse(style.size ?? "15"))
            : Styling.applyStyleV2(),
        errorStyle: const TextStyle(color: Colors.red),
        suffixIcon: suffixIcon());
  }

  suffixIcon() {
    return Icon(Icons.calendar_month_outlined,
        color: HexColor(AppState.instance.themeModel.textColor));
  }

  String? validation(String? value) {
    if (widget.viewModel.errorWidgetMap
        .containsKey(widget.widgetInfo.widgetId)) {
      String? errorMsg =
          widget.viewModel.errorWidgetMap[widget.widgetInfo.widgetId];
      if (_textEditingController.text.isNotEmpty) {
        widget.viewModel.errorWidgetMap.remove(widget.widgetInfo.widgetId);
        return null;
      }
      widget.viewModel.scrollToFirstValidationErrorWidget(context);
      errorMessage = errorMsg;
      return errorMsg;
    }
    return null;
  }

  Future<void> _selectDate(BuildContext context, bool isEndDate) async {
    DateTime initialDate = DateTime.now();
    String? hintText = widget.widgetInfo.widgetConfig.placeholderText;
    bool dateRangeEnabled =
        widget.widgetInfo.widgetConfig.additionalConfig!.dateRangeEnable ??
            false;
    DateTime? pickedDate = await showDatePicker(
      context: context,
      firstDate: dateRangeEnabled
          ? isEndDate
              ? rangeStartDate
              : DateTime(
                  initialDate.year,
                  initialDate.month,
                  initialDate.day -
                      widget.widgetInfo.widgetConfig.additionalConfig!
                          .historicalDays!)
          : DateTime(DateTime.now().year - 100),
      lastDate: dateRangeEnabled
          ? DateTime(
              initialDate.year,
              initialDate.month,
              initialDate.day +
                  widget.widgetInfo.widgetConfig.additionalConfig!.futureDays!)
          : DateTime(DateTime.now().year + 100),
      initialDate: isEndDate ? rangeStartDate : initialDate,
      helpText: dateRangeEnabled
          ? isEndDate
              ? 'Select end date'
              : 'Select start date'
          : (hintText?.isNotEmpty ?? false)
              ? hintText!
              : 'Select Date',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: HexColor(AppState.instance.themeModel.primaryColor),
              onPrimary: HexColor(AppState.instance.themeModel.backgroundColor),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: HexColor(AppState
                    .instance.themeModel.primaryColor), // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) {
      return;
    }

    if (dateRangeEnabled) {
      if (isEndDate) {
        rangeEndDate = pickedDate;
        setState(() {
          widget.viewModel.errorWidgetMap.remove(widget.widgetInfo.widgetId);
          String dateFormat = widget.widgetInfo.widgetConfig.additionalConfig!.dateFormat!;
          if (dateFormat.contains("ss")) { // for format like dd/MM/yyyy HH:mm:ss containing hour, minute and second info.
            rangeStartDate = DateTime(rangeStartDate.year, rangeStartDate.month, rangeStartDate.day, DateTime.now().hour, DateTime.now().minute, DateTime.now().second);
            rangeEndDate = DateTime(rangeEndDate.year, rangeEndDate.month, rangeEndDate.day, DateTime.now().hour, DateTime.now().minute, DateTime.now().second);
          }
          String convertedStartDate = Util.instance.setDynamicDateFormat(
              rangeStartDate,
              dateFormat);
          String convertedEndDate = Util.instance.setDynamicDateFormat(
              rangeEndDate,
              dateFormat);
          _textEditingController.text =
          '$convertedStartDate - $convertedEndDate';
          AppState.instance.addToFormTempMap(
              widget.widgetInfo.widgetId, '$rangeStartDate,$rangeEndDate');
        });
      } else {
        rangeStartDate = pickedDate;
        _selectDate(context, true);
      }
    } else {
      setState(() {
        widget.viewModel.errorWidgetMap.remove(widget.widgetInfo.widgetId);
        String dateFormat = widget.widgetInfo.widgetConfig.additionalConfig!.dateFormat!;
        if (dateFormat.contains("ss")) { // for format like dd/MM/yyyy HH:mm:ss containing hour, minute and second info.
          pickedDate = DateTime(pickedDate!.year, pickedDate!.month, pickedDate!.day, DateTime.now().hour, DateTime.now().minute, DateTime.now().second);
        }
        String convertedDate = Util.instance.setDynamicDateFormat(pickedDate!,
            dateFormat);
        _textEditingController.text = convertedDate;
        AppState.instance
            .addToFormTempMap(widget.widgetInfo.widgetId, pickedDate);
      });
    }
  }

  validationErrorWidget() {
    if (widget.viewModel.errorWidgetMap
        .containsKey(widget.widgetInfo.widgetId)) {
      widget.viewModel.scrollToFirstValidationErrorWidget(context);
      return Text(
        widget.viewModel.errorWidgetMap[widget.widgetInfo.widgetId]!,
        style: constants.smallRedTextStyle,
      );
    } else {
      return const SizedBox();
    }
  }
}
