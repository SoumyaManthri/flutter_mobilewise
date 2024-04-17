import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../shared/model/form_model.dart';
import '../../../../utils/app_state.dart';
import '../../../../utils/common_constants.dart' as constants;
import '../../../../utils/common_constants.dart';
import '../../../../utils/hex_color.dart';
import '../../../../utils/styling.dart';
import '../../../../utils/util.dart';
import '../../model/form_image_field_widget_media.dart';
import '../../view_model/form_view_model.dart';

class FormFilePickerWidget extends StatefulWidget {
  const FormFilePickerWidget({
    Key? key,
    required this.widgetInfo,
    required this.viewModel,
  }) : super(key: key);

  final WidgetInfo widgetInfo;
  final FormViewModel viewModel;

  @override
  State<FormFilePickerWidget> createState() => _FormFilePickerWidgetState();
}

class _FormFilePickerWidgetState extends State<FormFilePickerWidget> {
  static const String outlinedType = 'outlined';
  static const String filledType = 'filled';

  TextEditingController textEditingController = TextEditingController();

  final FocusNode _focus = FocusNode();
  final List<dynamic> _files = [];

  late String _widgetId;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _widgetId = widget.widgetInfo.widgetId;
    _initializeFiles();
    widget.viewModel.filePickerFields[_widgetId] = widget.widgetInfo;
  }

  @override
  Widget build(BuildContext context) {
    return _view();
  }

  _initializeFiles() {
    _files.clear();
    if (widget.viewModel.clickedSubmissionValuesMap.containsKey(_widgetId)) {
      String hashSeparatedString =
          widget.viewModel.clickedSubmissionValuesMap[_widgetId];
      List<String> fileNames = hashSeparatedString.split("#");
      for (String f in fileNames) {
        _files.add(FormImageFieldWidgetMedia(
            false, f, null, '${constants.s3BucketBaseUrl}$f'));
      }
    } else if (AppState.instance.formTempMap.containsKey(_widgetId)) {
      _files.addAll(AppState.instance.formTempMap[_widgetId]);
    }

    /// Initializing files to formTempMap
    AppState.instance.formTempMap[_widgetId] = List.from(_files);
  }

  TextFormField textField() {
    refreshText();

    return TextFormField(
      readOnly: false,
      focusNode: _focus,
      autovalidateMode: AutovalidateMode.always,
      showCursor: false,
      controller: textEditingController,
      keyboardType: TextInputType.none,
      enableInteractiveSelection: false,
      enableSuggestions: false,
      onTap: () {
        _focus.unfocus();
        onTap();
      },
      autocorrect: false,
      style: TextStyle(color: HexColor(AppState.instance.themeModel.textColor)),
      decoration: decoration(widget.widgetInfo.widgetConfig.matUiType),
      validator: (value) {
        return validation();
      },
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

  InputDecoration borderFilled() {
    WidgetConfigStyle style = widget.widgetInfo.widgetConfig.style;
    return InputDecoration(
        label: constants.mandatoryFieldV2(widget.widgetInfo),
        hintText: widget.widgetInfo.widgetConfig.placeholderText,
        hintStyle: const TextStyle(color: Color(constants.hintTextColor)),
        helperText: errorMessage,
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
            : applyStyleV2(),
        errorStyle: const TextStyle(color: Colors.red),
        suffixIcon: Icon(Icons.attach_file,
            color: HexColor(AppState.instance.themeModel.textColor)));
  }

  InputDecoration borderOutlined() {
    return InputDecoration(
        label: constants.mandatoryFieldV2(widget.widgetInfo),
        // labelText: widget.field.label,
        hintText: '${_files.length} file(s) selected',
        helperText: errorMessage,
        fillColor: HexColor(AppState.instance.themeModel.backgroundColor),
        filled: true,
        // floatingLabelBehavior: FloatingLabelBehavior.never,
        border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black)),
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black)),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: HexColor(AppState.instance.themeModel.textColor))),
        errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(width: 2, color: Colors.red)),
        floatingLabelStyle: TextStyle(
            color: HexColor(AppState.instance.themeModel.primaryColor)),
        labelStyle: const TextStyle(color: Colors.black),
        errorStyle: const TextStyle(color: Colors.red),
        suffixIcon: Icon(Icons.file_copy_outlined,
            color: HexColor(AppState.instance.themeModel.textColor)));
  }

  refreshText() {
    if (_files.isNotEmpty) {
      textEditingController.text = '${_files.length} file(s) selected';
    } else {
      textEditingController.text = '';
    }
  }

  validation() {
    if (widget.viewModel.errorWidgetMap.containsKey(_widgetId)) {
      widget.viewModel.scrollToFirstValidationErrorWidget(context);
      errorMessage = widget.viewModel.errorWidgetMap[_widgetId]!;
    }
    return null;
  }

  _view() {
    return Column(
      children: [
        Padding(
            padding: EdgeInsets.fromLTRB(
                0.0,
                Util.instance.getTopMarginFromWidgetInfo(widget.widgetInfo.widgetConfig.style),
                0.0,
                constants.smallPadding),
            child: textField()),
        _files.isNotEmpty
            ? SizedBox(
                width: MediaQuery.of(context).size.width,
                height: constants.fileThumbnailListHeight,
                child: _getFileThumbnails(),
              )
            : const SizedBox(),
      ],
    );
  }

  onTap() async {
    /// Checking for max limit on file capture
    /*if (widget.widgetInfo.widgetConfig.max != null &&
        widget.field.max! > 0 &&
        _files.length == widget.field.max!) {
      Util.instance.showSnackBar(context, constants.maxFileCaptureMessage);
      return;
    }*/

    /// Can attach more files
    /// 1. Open gallery for user to select files
    FilePickerResult? result;
    List<String>? fileType =
        widget.widgetInfo.widgetConfig.additionalConfig!.fileType!;

    if (fileType.isNotEmpty) {
      result = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: fileType);
    } else {
      result = await FilePicker.platform.pickFiles();
    }
    if (result != null) {
      await _createFile(result);
    } else {
      if (!mounted) return;
      Util.instance.showSnackBar(context, constants.fileCaptureErrorMessage);
    }
  }

  /// Create file selected from FilePicker
  _createFile(FilePickerResult result) async {
    File file = File(result.files.single.path!);
    int? maxSize = widget.widgetInfo.widgetConfig.additionalConfig!.maxSize;
    if (await isSizeWithinLimit(file, maxSize)) {
      String mimeType = file.path.split(".").last;

      /// after successful file upload remove the error field from the map
      widget.viewModel.errorWidgetMap.remove(_widgetId);

      /// Reading XFile image as Uint8List
      Uint8List data = await file.readAsBytes();
      final directory = await getApplicationDocumentsDirectory();

      /// Creating File using Uint8List
      /// Name of file is [Time based V1 UUID]
      String basename = '${const Uuid().v1()}.$mimeType';
      File newFile = await File('${directory.path}/$basename').create();
      newFile.writeAsBytesSync(data);

      /// Setting state so that thumbnails of uploaded files can be shown
      setState(() {
        _files
            .add(FormImageFieldWidgetMedia(true, basename, newFile.path, null));
      });
      addFileToSubmissionMap();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("File should be less than $maxSize MB"),
      ));
    }
  }

  isSizeWithinLimit(File file, int? size) async {
    int fileSizeInBytes = await file.length();

    // Convert the size to megabytes
    double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

    if (size == null || fileSizeInMB <= size) {
      return true;
    } else {
      return false;
    }
  }

  addFileToSubmissionMap() {
    AppState.instance.addToFormTempMap(_widgetId, _files);
  }

  removeFromSubmissionMap(FormImageFieldWidgetMedia file) {
    List<dynamic> existingFiles = [];
    existingFiles.addAll(AppState.instance.formTempMap[_widgetId]);
    if (existingFiles.isNotEmpty) {
      existingFiles.remove(file);
      AppState.instance.addToFormTempMap(_widgetId, existingFiles);
      if (file.isLocal) {
        File tempFile = File(file.path!);
        tempFile.delete();
      }
    }
  }

  _getFileThumbnails() {
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _files.length,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
              onTap: () {
                _openFile(_files[index]);
              },
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      0.0, 0.0, constants.smallPadding, constants.smallPadding),
                  child: Container(
                      height: constants.fileThumbnailHeight,
                      width: constants.fileThumbnailWidth,
                      decoration: BoxDecoration(
                        color: const Color(0xFFdae3dc),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            Util.instance.getImageForMimeType(
                                _files[index].name.split(".")[1]),
                            height: constants.mimeTypeImageHeight,
                            width: constants.mimeTypeImageWidth,
                          ),
                          Row(
                            children: [
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      constants.xSmallPadding, 0.0, 0.0, 0.0),
                                  child: Tooltip(
                                    message: _files[index].name,
                                    child: Text(
                                      _files[index].name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ))));
        });
  }

  _getVerticalFileThumbnails() {
    return ListView.builder(
        itemCount: _files.length,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () {
              _openFile(_files[index]);
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  0.0, 0.0, 0.0, constants.smallPadding),
              child: Container(
                  height: 40,
                  width: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFFdae3dc),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        Util.instance.getImageForMimeType(
                            _files[index].name.split(".")[1]),
                        height: 22,
                        width: 22,
                      ),
                      Flexible(
                        child: Tooltip(
                          message: _files[index].name,
                          child: Text(_files[index].name,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ],
                  )),
            ),
          );
        });
  }

  _getThumbnailPlaceholderHeight() {
    if (_files.isEmpty) {
      return 0.0;
    }
    if (_files.length >= 5) {
      return constants.maxFileThumbnailHeight;
    }
    return _files.length * constants.minFileThumbnailHeight;
  }

  _openFile(FormImageFieldWidgetMedia file) {
    if (file.isLocal) {
      /// We have the path for this file
      OpenFilex.open(file.path!);
    } else {
      /// Online file
      /// 1. Download the file from S3
      /// 2. Create a temporary file
      /// 3. Open the file
    }
  }
}
