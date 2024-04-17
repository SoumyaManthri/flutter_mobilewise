import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../screens/forms/model/form_image_field_widget_media.dart';
import '../../../../screens/forms/view_model/form_view_model.dart';
import '../../../../shared/model/form_model.dart';
import '../../../../utils/app_state.dart';
import '../../../../utils/common_constants.dart' as constants;
import '../../../../utils/hex_color.dart';
import '../../../../utils/navigation_util.dart';
import '../../../../utils/styling.dart';
import '../../../../utils/util.dart';
import 'package:path/path.dart' as path;

class FormImageFieldWidget extends StatefulWidget {
  const FormImageFieldWidget({
    Key? key,
    required this.viewModel,
    required this.widgetInfo
  }) : super(key: key);

  final FormViewModel viewModel;
  final WidgetInfo widgetInfo;

  @override
  State<FormImageFieldWidget> createState() => _FormImageFieldWidgetState();
}

class _FormImageFieldWidgetState extends State<FormImageFieldWidget> {
  static const String outlinedType = 'outlined';
  static const String filledType = 'filled';
  TextEditingController textEditingController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<dynamic> _images = [];
  String? errorMessage;
  FocusNode focus = FocusNode();
  String uploadType = '';
  double? bearing;
  double? latitude;
  double? longitude;

  @override
  void initState() {
    if (widget.widgetInfo.widgetConfig.additionalConfig!.uploadType != null &&
        widget.widgetInfo.widgetConfig.additionalConfig!.uploadType!.isNotEmpty) {
      uploadType = widget.widgetInfo.widgetConfig.additionalConfig!.uploadType!;
    }
    /// Initialize images
    _initializeImages();
    widget.viewModel.imageFields[widget.widgetInfo.widgetId] = widget.widgetInfo;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _view();
  }

  _initializeImages() {
    _images.clear();
    if (widget.viewModel.clickedSubmissionValuesMap
        .containsKey(widget.widgetInfo.widgetId)) {
      String hashSeparatedString =
          widget.viewModel.clickedSubmissionValuesMap[widget.widgetInfo.widgetId];
      List<String> imageNames = hashSeparatedString.split('#');
      for (String i in imageNames) {
        _images.add(FormImageFieldWidgetMedia(
            false, i, null, '${constants.s3BucketBaseUrl}$i'));
      }
    } else if (AppState.instance.formTempMap.containsKey(widget.widgetInfo.widgetId)) {
      _images.addAll(AppState.instance.formTempMap[widget.widgetInfo.widgetId]);
    }

    /// Initializing images to formTempMap
    AppState.instance.formTempMap[widget.widgetInfo.widgetId] = [];
    AppState.instance.formTempMap[widget.widgetInfo.widgetId].addAll(_images);
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
        _images.isNotEmpty
            ? SizedBox(
                width: MediaQuery.of(context).size.width,
                height:uploadType == constants.videoUpload ?
                constants.fileThumbnailHeight:
                constants.cameraPlaceholderImageHeight,
                child:
                     uploadType == constants.videoUpload ? _getVideoThumnail():_getImageThumbnails(),
              )
            : const SizedBox(),
      ],
    );
  }


  TextFormField textField() {
    refreshText();

    return TextFormField(
      readOnly: false,
      focusNode: focus,
      autovalidateMode: AutovalidateMode.always,
      showCursor: false,
      controller: textEditingController,
      keyboardType: TextInputType.none,
      enableInteractiveSelection: false,
      enableSuggestions: false,
      onTap: () {
        focus.unfocus();
        if (uploadType.isNotEmpty) {
          onTap();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(constants.notUploadedVideo),
          ));
        }
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
    if (type == null) {
      return const InputDecoration();
    }
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
      enabledBorder:   UnderlineInputBorder(
          borderSide: BorderSide(color: HexColor(AppState.instance.themeModel.textColor))),
      errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(width: 2, color: Colors.red)),
      floatingLabelStyle:
      TextStyle(color: HexColor(AppState.instance.themeModel.primaryColor)),
      labelStyle: style != null
          ? Styling.applyStyleV2(
          bold: (style.fontWeight ?? 'normal') != 'normal',
          underline: (style.textDecoration ?? 'none') != 'none',
          italics: (style.fontStyle ?? 'normal') != 'normal',
          color: style.color,
          size: int.parse(style.size ?? "15"))
          : Styling.applyStyleV2(),
      errorStyle: const TextStyle(color: Colors.red),
      suffixIcon: Icon(Icons.camera_alt_outlined,
          color: HexColor(AppState.instance.themeModel.textColor))
    );
  }

  InputDecoration borderOutlined() {
    return InputDecoration(
        label: constants.mandatoryFieldV2(widget.widgetInfo),
        // labelText: widget.field.label,
        hintText: '${_images.length} $uploadType(s) selected',
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
        suffixIcon: Icon(Icons.camera_alt_outlined,
            color: HexColor(AppState.instance.themeModel.textColor)));
  }


  String getFileExtension(String filePath) {
    // Find the last occurrence of '.' in the file path
    int dotIndex = filePath.lastIndexOf('.');
    // Check if a dot was found and it is not the last character in the path
    if (dotIndex != -1 && dotIndex < filePath.length - 1) {
      // Extract the substring starting from the dot to the end of the path
      return filePath.substring(dotIndex);
    }
    // Return null or an empty string if no valid extension is found
    return ""; // or return an empty string: ''
  }

  onTap() async {
    if (uploadType == constants.videoUpload) {
      int value = 1;
      if (widget.widgetInfo.widgetConfig.additionalConfig!.galleryUpload ?? false) {
        value = await videoBottomSheet();
      }

      XFile? video;
      if (value == 1) {
        video = await _picker.pickVideo(source: ImageSource.camera);
        await setGeoReference();
      } else {
        video = await _picker.pickVideo(source: ImageSource.gallery);
      }

      if (video != null) {
        String extension = path.extension(video.path);

        // Allowed types
        List<String>? allowedTypes = widget.widgetInfo.widgetConfig.additionalConfig!.allowedTypes;
        // Check if the extension is in the allowed types
        if (!allowedTypes!.contains(extension.substring(1).toUpperCase())) {
          ScaffoldMessenger.of(context).showSnackBar( SnackBar(
            content: Text("Kindly upload the video in ${allowedTypes.join(', ')} formats only."),
          ));
          return;
        }

        if (await isSizeWithinLimit(video, widget.widgetInfo.widgetConfig.additionalConfig!.maxSize)) {
          /// after successful image capture remove the error field from the map
          widget.viewModel.errorWidgetMap.remove(widget.widgetInfo.widgetId);

          /// Reading XFile image as Uint8List
          Uint8List data = await video.readAsBytes();
          final directory = await getApplicationDocumentsDirectory();
          String fileExtension = getFileExtension(video.path);
          /// Creating File using Uint8List
          /// Name of file is [userId_currentTimeInMs]
          String basename = '${const Uuid().v1()}$fileExtension';
          File file = await File('${directory.path}/$basename').create();
          file.writeAsBytesSync(data);
          String thumbnailFileName = '${const Uuid().v1()}.png';

          Uint8List? thumbnailData = await AppState.instance.generateThumbnailForLocal(file.path);
          String thumbnailFilePath = '${directory.path}/$thumbnailFileName';
          await AppState.instance.saveThumbnailToFile(thumbnailData, thumbnailFilePath);
          /// Setting state so that thumbnails of captured images can be shown
          setState(() {
            _images.add(
                FormImageFieldWidgetMedia(true, basename, file.path, null,thumbnailLocalPath: thumbnailFilePath, bearing: bearing, latitude: latitude, longitude: longitude));
          });
          _addImageToSubmissionMap();
        } else {
          ScaffoldMessenger.of(context).showSnackBar( SnackBar(
            content: Text("Video should be less than ${widget.widgetInfo.widgetConfig.additionalConfig!.maxSize} MB"),
          ));
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Video is not uploaded"),
        ));
      }
    } else if (uploadType == constants.image) {
      /// Checking for max limit on image capture
      /*if (widget.field.max != null &&
          widget.field.max! > 0 &&
          _images.length == widget.field.max!) {
        /// Limit reached, cannot capture any more images
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(constants.maxImageCaptureMessage),
        ));*/
      //} else {
        /// Can capture more images
        /// 1. Open dialog to let the user choose between camera/gallery
        /// 2. Based on user choice either open camera, OR open gallery
        /// for the user to upload
        int value = 1;
        if (widget.widgetInfo.widgetConfig.additionalConfig!.galleryUpload ?? false) {
          value = await imageBottomSheet();
        }
        if (value == 1 || value == 2) {
          XFile? photo;
          if (value == 1) {
            photo = await _picker.pickImage(source: ImageSource.camera);
            await setGeoReference();
          } else {
            photo = await _picker.pickImage(source: ImageSource.gallery);
            if (photo == null) {
              return;
            }

            String extension = path.extension(photo.path);

            // Allowed types
            List<String>? allowedTypes = widget.widgetInfo.widgetConfig.additionalConfig!.allowedTypes;
            // Check if the extension is in the allowed types
            if (!allowedTypes!.contains(extension.substring(1).toUpperCase())) {
              ScaffoldMessenger.of(context).showSnackBar( SnackBar(
                content: Text("Kindly upload the images in ${allowedTypes.join(', ')} formats only."),
              ));
              return;
            }
          }

          if (photo != null) {
            if (await isSizeWithinLimit(photo, widget.widgetInfo.widgetConfig.additionalConfig!.maxSize)) {
              /// after successful image capture remove the error field from the map
              widget.viewModel.errorWidgetMap.remove(widget.widgetInfo.widgetId);

              /// Reading XFile image as Uint8List
              Uint8List data = await photo.readAsBytes();
              final directory = await getApplicationDocumentsDirectory();

              /// Creating File using Uint8List
              /// Name of file is [userId_currentTimeInMs]
              String basename = value == 2 ? photo.name : '${const Uuid().v1()}.png';
              File file = await File('${directory.path}/$basename').create();
              file.writeAsBytesSync(data);

              /// Setting state so that thumbnails of captured images can be shown
              setState(() {
                _images.add(
                    FormImageFieldWidgetMedia(true, basename, file.path, null, bearing: bearing, latitude: latitude, longitude: longitude));
              });
              _addImageToSubmissionMap();
            } else{
              ScaffoldMessenger.of(context).showSnackBar( SnackBar(
                content: Text("Image should be less than ${widget.widgetInfo.widgetConfig.additionalConfig!.maxSize} MB"),
              ));
            }
          } else {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(constants.imageCaptureErrorMessage),
            ));
          }
        }
      //}
    }else {
      //todo
    }
  }

  Future<void> setGeoReference() async {
    if (widget.widgetInfo.widgetConfig.additionalConfig?.geoReference == true) {
      final hasBearingToggle = widget.widgetInfo.widgetConfig.additionalConfig!.baringToggle;
      final compassEvent = await FlutterCompass.events!.first;

      if (hasBearingToggle == true) {
        bearing = compassEvent.heading;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      latitude = position.latitude;
      longitude = position.longitude;
    }
  }

  isSizeWithinLimit(XFile file, int? size) async {
    int fileSizeInBytes = await file.length();

    // Convert the size to megabytes
    double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

    if (size == null || fileSizeInMB <= size) {
      return true;
    } else {
      return false;
    }
  }

  refreshText() {
    if (_images.isNotEmpty) {
      textEditingController.text = '${_images.length} $uploadType(s) selected';
    } else {
      textEditingController.text = '';
    }
  }

  validation() {
    if (widget.viewModel.errorWidgetMap.containsKey(widget.widgetInfo.widgetId)) {
      widget.viewModel.scrollToFirstValidationErrorWidget(context);
      errorMessage = widget.viewModel.errorWidgetMap[widget.widgetInfo.widgetId]!;
    }
    return null;
  }

  _addImageToSubmissionMap() {
    AppState.instance.addToFormTempMap(widget.widgetInfo.widgetId, _images);
  }

  _removeFromSubmissionMap(FormImageFieldWidgetMedia image) {
    List<dynamic> existingImages = [];
    existingImages.addAll(AppState.instance.formTempMap[widget.widgetInfo.widgetId]);
    if (existingImages.isNotEmpty) {
      existingImages.remove(image);
      AppState.instance.addToFormTempMap(widget.widgetInfo.widgetId, existingImages);
      if (image.isLocal) {
        /// Deleting the file
        File file = File(image.path!);
        file.delete();
      }
    }
  }

  _getImageThumbnails() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _images.length,
      itemBuilder: (BuildContext context, int index) {
        if (_images[index].isLocal) {
          /// Image is a local image from current form session
          String? path = _images[index].path;
          if (path != null && path.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(
                0.0,
                0.0,
                constants.mediumPadding,
                constants.mediumPadding,
              ),
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  InkWell(
                    onTap: () {
                      NavigationUtil.instance.navigateToImagePreviewScreen(
                          context, _images[index]);
                    },
                    child: SizedBox(
                      height: constants.cameraPlaceholderImageHeight,
                      child: Image.file(
                        File(path),
                        errorBuilder: (BuildContext context, Object exception,
                            StackTrace? stackTrace) {
                          Util.instance.logMessage('Image Field Widget',
                              'Image.file failed -- $exception');
                          return Container(
                            height: constants.cameraPlaceholderImageHeight,
                            width: constants.networkImageErrorPlaceholderWidth,
                            decoration:
                                constants.networkImageContainerDecoration,
                            child: const Center(
                              child: Icon(
                                Icons.broken_image,
                                color:
                                    Color(constants.formFieldBackgroundColor),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  InkWell(
                          onTap: () {
                            setState(() {
                              _removeFromSubmissionMap(
                                  _images.elementAt(index));
                              _images.removeAt(index);
                              refreshText();
                            });
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.all(constants.smallPadding),
                            child: Container(
                              padding:
                                  const EdgeInsets.all(constants.xSmallPadding),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: constants.closeIconDimension,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            );
          } else {
            return const SizedBox();
          }
        } else {
          /// Image is an online image submitted from an older session
          String? url = _images[index].url;
          if (url != null && url.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(
                0.0,
                0.0,
                constants.mediumPadding,
                0.0,
              ),
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  InkWell(
                    onTap: () {
                      NavigationUtil.instance
                          .navigateToImagePreviewScreen(context, _images[index]);
                    },
                    child: SizedBox(
                      height: constants.cameraPlaceholderImageHeight,
                      child: Image.network(
                        url,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: constants.cameraPlaceholderImageHeight,
                            width: constants.networkImageErrorPlaceholderWidth,
                            decoration:
                                constants.networkImageContainerDecoration,
                            child: Center(
                              child: constants.blackIndicator,
                            ),
                          );
                        },
                        errorBuilder: (BuildContext context, Object exception,
                            StackTrace? stackTrace) {
                          Util.instance.logMessage('Image Field Widget',
                              'Image.network failed -- $exception');
                          return Container(
                            height: constants.cameraPlaceholderImageHeight,
                            width: constants.networkImageErrorPlaceholderWidth,
                            decoration:
                                constants.networkImageContainerDecoration,
                            child: const Center(
                              child: Icon(
                                Icons.broken_image,
                                color:
                                    Color(constants.formFieldBackgroundColor),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  InkWell(
                          onTap: () {
                            setState(() {
                              _removeFromSubmissionMap(
                                  _images.elementAt(index));
                              _images.removeAt(index);
                              refreshText();
                            });
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.all(constants.smallPadding),
                            child: Container(
                              padding:
                                  const EdgeInsets.all(constants.xSmallPadding),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: constants.closeIconDimension,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            );
          } else {
            return const SizedBox();
          }
        }
      },
    );
  }


  _getVideoThumnail() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _images.length,
      itemBuilder: (BuildContext context, int index) {
        if (_images[index].isLocal) {
          /// Image is a local image from current form session
          String? path = _images[index].path;
          String thumbnailPath = _images[index].thumbnailLocalPath;

          if (path != null && path.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(
                0.0,
                0.0,
                constants.mediumPadding,
                0.0,
              ),
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  InkWell(
                    child: SizedBox(
                      height: constants.cameraPlaceholderImageHeight,
                      child: InkWell(
                        onTap: () => AppState.instance.navigateToPreviewScreen(_images[index], context),
                        child: Stack(
                          children: <Widget>[
                            SizedBox(
                              height: 80,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  fit: BoxFit.fill,
                                  width: 80,
                                  height: 70,
                                  File(thumbnailPath),
                                  errorBuilder: (BuildContext context, Object exception,
                                      StackTrace? stackTrace) {
                                    Util.instance.logMessage('Image Field Widget',
                                        'Image.file failed -- $exception');
                                    return Container(
                                      height: constants.networkImageErrorPlaceholderWidth,
                                      width: constants.networkImageErrorPlaceholderWidth,
                                      decoration:
                                      constants.networkImageContainerDecoration,
                                      child: const Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          color:
                                          Color(constants.formFieldBackgroundColor),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const Positioned(
                              top: 24.0,
                              left: 24.0,
                              child: Icon(
                                Icons.play_circle_filled,
                                color: Colors.white,
                                size: 32.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _removeFromSubmissionMap(
                            _images.elementAt(index));
                        _images.removeAt(index);
                        refreshText();
                      });
                    },
                    child: Padding(
                      padding:
                      const EdgeInsets.all(constants.xSmallPadding),
                      child: Container(
                        padding:
                        const EdgeInsets.all(constants.xSmallPadding),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: constants.closeIconDimension,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const SizedBox();
          }
        } else {
          /// Image is an online image submitted from an older session
          String? url = _images[index].url;
          if (url != null && url.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(
                0.0,
                0.0,
                constants.mediumPadding,
                0.0,
              ),
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  InkWell(
                    onTap: () {
                      AppState.instance.navigateToPreviewScreen(_images[index], context);
                    },
                    child: SizedBox(
                      height: constants.cameraPlaceholderImageHeight,
                      child: Image.network(
                        url,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: constants.cameraPlaceholderImageHeight,
                            width: constants.networkImageErrorPlaceholderWidth,
                            decoration:
                            constants.networkImageContainerDecoration,
                            child: Center(
                              child: constants.blackIndicator,
                            ),
                          );
                        },
                        errorBuilder: (BuildContext context, Object exception,
                            StackTrace? stackTrace) {
                          Util.instance.logMessage('Image Field Widget',
                              'Image.network failed -- $exception');
                          return Container(
                            height: constants.cameraPlaceholderImageHeight,
                            width: constants.networkImageErrorPlaceholderWidth,
                            decoration:
                            constants.networkImageContainerDecoration,
                            child: const Center(
                              child: Icon(
                                Icons.broken_image,
                                color:
                                Color(constants.formFieldBackgroundColor),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                      InkWell(
                    onTap: () {
                      setState(() {
                        _removeFromSubmissionMap(
                            _images.elementAt(index));
                        _images.removeAt(index);
                        refreshText();
                      });
                    },
                    child: Padding(
                      padding:
                      const EdgeInsets.all(constants.smallPadding),
                      child: Container(
                        padding:
                        const EdgeInsets.all(constants.xSmallPadding),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: constants.closeIconDimension,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const SizedBox();
          }
        }
      },
    );
  }

  Future<int> videoBottomSheet() async {
    int value = await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
                leading: const Icon(Icons.video_camera_front_rounded),
                title: const Text(constants.videoDialogCamera),
                onTap: () {
                  Navigator.pop(context, 1);
                }),
            ListTile(
                leading: const Icon(Icons.video_library),
                title: const Text(constants.videoDialogGallery),
                onTap: () {
                  Navigator.pop(context, 2);
                })
          ],
        );
      },
    );

    return value;
  }
  
  Future<int> imageBottomSheet() async {
    int value = await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text(constants.imageDialogCamera),
                onTap: () {
                  Navigator.pop(context, 1);
                }),
            ListTile(
                leading: const Icon(Icons.photo),
                title: const Text(constants.imageDialogGallery),
                onTap: () {
                  Navigator.pop(context, 2);
                })
          ],
        );
      },
    );

    return value;
  }
}
