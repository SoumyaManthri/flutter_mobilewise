import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../screens/forms/view_model/edittext_view_model.dart';
import '../../../../screens/forms/view_model/form_view_model.dart';
import '../../../../shared/model/framework_form.dart';
import '../../../../utils/app_state.dart';
import '../../../../utils/common_constants.dart' as constants;
import '../../../../utils/common_constants.dart';
import '../../../../utils/hex_color.dart';
import '../../../../utils/util.dart';

class FormEdittextFieldWidget extends StatefulWidget {
  const FormEdittextFieldWidget({
    Key? key,
    required this.field,
    required this.fieldKey,
    required this.viewModel,
    required this.position,
    required this.focusList,
  }) : super(key: key);

  final FrameworkFormField field;
  final String fieldKey;
  final FormViewModel viewModel;
  final int position;
  final List<FocusNode>? focusList;

  @override
  State<FormEdittextFieldWidget> createState() =>
      _FormEdittextFieldWidgetState();
}

class _FormEdittextFieldWidgetState extends State<FormEdittextFieldWidget> {

  static const int numberType = 2;
  static const int passwordType = 3;
  static const String outlinedType = 'outlined';
  static const String filledType = 'filled';

  late TextEditingController textEditingController;
  late EditTextViewModel editTextViewModel;
  List<TextInputFormatter> inputFormatters = [];
  TextInputType keyboardType = TextInputType.text;

  String initValue = '';

  bool isFocused = true;
  bool _textVisible = true;

  @override
  void initState() {
    editTextViewModel = Provider.of<EditTextViewModel>(context, listen: false);
    _textVisible = false;

    /// Initialize edittext keyboard type and validations
    _initEdittextKeyboard();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      editTextViewModel.setLength(widget.fieldKey, initValue.length);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /// Initializing edittext value
    _initEdittextValue();

    if (widget.focusList != null &&
        widget.focusList![widget.position].hasFocus) {
      isFocused = true;
    }

    /// Widget
    /// 1. The widget can be editable by the user
    /// 2. If it is not editable, then we just show the label and the user entered value
    /// 3. If it is not editable, and the user has not entered any value, then
    /// nothing is rendered
    return widget.field.isEditable
        ? Padding(
            padding: EdgeInsets.fromLTRB(
                0.0,
                Util.instance.getTopMargin(widget.field.style),
                0.0,
                constants.mediumPadding),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  textField(widget.field.type),
                  widget.field.max != null && widget.field.max! > 0
                      ? Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Consumer<EditTextViewModel>(
                                builder: (_, model, child) {
                              return Text(
                                '${editTextViewModel.keyToLengthMap[widget.fieldKey] ?? 0}/${widget.field.max!}',
                                style: constants.smallGreyTextStyle,
                              );
                            }),
                          ],
                        )
                      : const SizedBox(),
                ],
              ),
            ),
          )
        : initValue.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.fromLTRB(
                    constants.mediumPadding,
                    constants.smallPadding,
                    constants.mediumPadding,
                    constants.smallPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /* Text(
                      widget.field.label,
                      style: constants.smallGreyTextStyle,
                    ),*/
                    mandatoryField(widget.field),
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

  /// This method is called to initialize edittext value
  _initEdittextValue() {
    if (widget.field.isEditable &&
        AppState.instance.formTempMap.containsKey(widget.fieldKey)) {
      initValue = AppState.instance.formTempMap[widget.fieldKey];
      textEditingController = TextEditingController(text: initValue);
      textEditingController.selection = TextSelection.fromPosition(
          TextPosition(offset: textEditingController.text.length));
    } else if (widget.viewModel.clickedSubmissionValuesMap
        .containsKey(widget.fieldKey)) {
      initValue = widget.viewModel.clickedSubmissionValuesMap[widget.fieldKey];
      textEditingController = TextEditingController(text: initValue);
      textEditingController.selection = TextSelection.fromPosition(
          TextPosition(offset: textEditingController.text.length));
    } else {
      textEditingController = TextEditingController();
    }
  }

  _initEdittextKeyboard() {
    if (widget.field.max != null && widget.field.max! > 0) {
      inputFormatters.add(LengthLimitingTextInputFormatter(widget.field.max!));
    }
    if (widget.field.type == numberType) {
      if (Platform.isAndroid) {
        keyboardType = TextInputType.number;
      } else {
        keyboardType =
            const TextInputType.numberWithOptions(signed: true, decimal: true);
      }
      inputFormatters.add(
        FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
      );
    }
  }

  TextFormField textField([int type = 1]) {
    return TextFormField(
      autovalidateMode: AutovalidateMode.always,
      enabled: widget.field.isEditable,
      cursorColor: Color(AppState.instance.textHexColor),
      controller: textEditingController,
      obscureText:
          widget.field.type == passwordType ? !_textVisible : _textVisible,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      showCursor: isFocused,
      enableSuggestions: false,
      autocorrect: false,
      textInputAction: widget.focusList != null &&
              widget.focusList!.length - 1 == widget.position
          ? TextInputAction.done
          : TextInputAction.next,
      focusNode: widget.focusList![widget.position],
      decoration: decoration(widget.field.matUiType),
      onFieldSubmitted: (value) {
        fieldSubmission(value);
      },
      validator: (value) {
        return validation(value);
      },
      onChanged: (value) {
        editTextViewModel.setLength(widget.fieldKey, value.length);
        AppState.instance.addToFormTempMap(widget.fieldKey, value.trim());
      },
      style: TextStyle(color: HexColor(AppState.instance.themeModel.textColor)),
    );
  }

  InputDecoration decoration(String type) {
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
      label: mandatoryField(widget.field),
      hintText: widget.field.hint,
      hintStyle: const TextStyle(color: Color(constants.hintTextColor)),
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
      enabledBorder:
            OutlineInputBorder(borderSide: BorderSide(color: HexColor(AppState.instance.themeModel.textColor))),
      errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(width: 2, color: Colors.red)),
      floatingLabelStyle:
          TextStyle(color: HexColor(AppState.instance.themeModel.primaryColor)),
      labelStyle: const TextStyle(color: Color(constants.hintTextColor)),
      errorStyle: const TextStyle(color: Colors.red),
      suffixIcon: widget.field.type == passwordType
          ? IconButton(
              icon: Icon(_textVisible ? Icons.visibility : Icons.visibility_off,
                  color: HexColor(AppState.instance.themeModel.textColor)),
              onPressed: () {
                setState(() {
                  _textVisible = !_textVisible;
                });
              },
            )
          : null,
    );
  }

  InputDecoration borderFilled() {
    FrameworkFormStyle? style = widget.field.style;
    return InputDecoration(
      label: mandatoryField(widget.field),
      hintText: widget.field.hint,
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
      enabledBorder:   UnderlineInputBorder(
          borderSide: BorderSide(color: HexColor(AppState.instance.themeModel.textColor))),
      errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(width: 2, color: Colors.red)),
      floatingLabelStyle:
          TextStyle(color: HexColor(AppState.instance.themeModel.primaryColor)),
      labelStyle: style != null
          ? applyStyleV2(
              bold: style.bold,
              underline: style.underline,
              italics: style.italics,
              color: style.color,
              size: style.size)
          : applyStyleV2(),
      errorStyle: const TextStyle(color: Colors.red),
      suffixIcon: widget.field.type == passwordType
          ? IconButton(
              icon: Icon(_textVisible ? Icons.visibility : Icons.visibility_off,
                  color: Color(AppState.instance.textHexColor)),
              onPressed: () {
                setState(() {
                  _textVisible = !_textVisible;
                });
              },
            )
          : null,
    );
  }

  String? validation(String? value) {
    if (widget.viewModel.errorWidgetMap.containsKey(widget.field.key)) {
      String? errorMsg = widget.viewModel.errorWidgetMap[widget.field.key];
      widget.viewModel.scrollToFirstValidationErrorWidget(context);
      widget.viewModel.errorWidgetMap.remove(widget.field.key);
      return errorMsg;
    }
    return null;
  }

  void fieldSubmission(String value) {
    widget.focusList![widget.position].unfocus();
    setState(() {
      isFocused = false;
    });
    if (widget.focusList!.length - 1 > widget.position) {
      if (widget.focusList != null) {
        FocusScope.of(context)
            .requestFocus(widget.focusList![widget.position + 1]);
      }
    } else {
      Future.delayed(const Duration(milliseconds: 300), () {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      });
    }
  }
}
