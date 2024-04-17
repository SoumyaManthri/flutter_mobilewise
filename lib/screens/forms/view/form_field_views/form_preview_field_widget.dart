import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:open_filex/open_filex.dart';

import '../../../../screens/forms/model/form_image_field_widget_media.dart';
import '../../../../screens/forms/view_model/form_view_model.dart';
import '../../../../shared/model/form_model.dart';
import '../../../../shared/model/framework_form.dart';
import '../../../../utils/app_state.dart';
import '../../../../utils/common_constants.dart' as constants;
import '../../../../utils/form_renderer_util.dart';
import '../../../../utils/navigation_util.dart';
import '../../../../utils/util.dart';
import '../form_field_v2/form_field_geofence_values_widget.dart';

class FormPreviewFieldWidget extends StatefulWidget {
  const FormPreviewFieldWidget({
    Key? key,
    required this.widgetInfo,
    required this.viewModel,
    required this.field,
  }) : super(key: key);

  final WidgetInfo widgetInfo;
  final FormViewModel viewModel;
  final FrameworkFormField field;

  @override
  State<FormPreviewFieldWidget> createState() => _FormPreviewFieldWidgetState();
}

class _FormPreviewFieldWidgetState extends State<FormPreviewFieldWidget> {
  String value = '';
  List<dynamic> images = [];
  List<dynamic> files = [];

  late String _widgetId;
  late String _widgetType;

  String? _uploadType;

  @override
  void initState() {
    super.initState();
    _initValue();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.setScrollToTop();
    });
  }

  _initValue() {
    images.clear();
    files.clear();

    _widgetId = widget.widgetInfo.widgetId;
    _widgetType = widget.widgetInfo.widgetType;
    _uploadType = widget.widgetInfo.widgetType;

    if (AppState.instance.formTempMap.containsKey(_widgetId)) {
      if (_widgetType == constants.image) {
        images.addAll(AppState.instance.formTempMap[_widgetId]);
      } else if (_widgetType == constants.filePicker) {
        files.addAll(AppState.instance.formTempMap[_widgetId]);
      } else if (_widgetType == constants.date) {
        String dateString = AppState.instance.formTempMap[_widgetId].toString();
        String? dateFormat = widget.widgetInfo.widgetConfig.additionalConfig!.dateFormat ?? "dd-MM-yyyy";
        if (dateString.contains(',')) {
          List<String> dateRange = dateString.split(',');
          DateTime start = DateTime.parse(dateRange[0]);
          DateTime end = DateTime.parse(dateRange[1]);
          String startDate = Util.instance.setDynamicDateFormat(start, dateFormat);
          String endDate = Util.instance.setDynamicDateFormat(end, dateFormat);
          value = '$startDate - $endDate';
        } else {
          value = Util.instance.setDynamicDateFormat(AppState.instance.formTempMap[_widgetId], dateFormat);
        }
      } else {
        value = AppState.instance.formTempMap[_widgetId];
      }
    } else if (widget.viewModel.clickedSubmissionValuesMap
        .containsKey(_widgetId)) {
      if (_widgetType == constants.image) {
        String hashSeparatedString =
            widget.viewModel.clickedSubmissionValuesMap[_widgetId];
        List<String> imageNames = hashSeparatedString.split('#');
        for (String i in imageNames) {
          images.add(FormImageFieldWidgetMedia(
              false, i, null, '${constants.s3BucketBaseUrl}$i'));
        }
        images.addAll(
            widget.viewModel.clickedSubmissionValuesMap[_widgetId]);
      } else if (_widgetType == constants.filePicker) {
        String hashSeparatedString =
            widget.viewModel.clickedSubmissionValuesMap[_widgetId];
        List<String> imageNames = hashSeparatedString.split('#');
        for (String i in imageNames) {
          files.add(FormImageFieldWidgetMedia(
              false, i, null, '${constants.s3BucketBaseUrl}$i'));
        }
        files.addAll(
            widget.viewModel.clickedSubmissionValuesMap[_widgetId]);
      } else if (_widgetType == constants.date) {
        value = Util.instance.getDisplayDate(
            widget.viewModel.clickedSubmissionValuesMap[_widgetId]);
      } else {
        value = widget.viewModel.clickedSubmissionValuesMap[_widgetId];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty && images.isEmpty && files.isEmpty) {
      return const SizedBox();
    }
    switch (_widgetType) {
      case constants.image:
        return Padding(
          padding: const EdgeInsets.only(bottom: constants.mediumPadding),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: constants.mediumPadding,
                vertical: constants.smallPadding),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${widget.widgetInfo.widgetLabel}:",
                        style: constants.smallGreyTextStyle,
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(top: constants.mediumPadding),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: _uploadType ==
                                  constants.videoUpload
                              ? constants.fileThumbnailHeight
                              : constants.cameraPlaceholderImageHeight,
                          child: images.isEmpty
                              ? const Image(
                                  image: AssetImage(constants.defaultImage),
                                  fit: BoxFit.fill,
                                )
                              : _uploadType !=
                                          null &&
                                      _uploadType ==
                                          constants.videoUpload
                                  ? _getVideoThumnail()
                                  : _getImageThumbnails(),
                        ),
                      ),
                    ])),
          ),
        );
      case constants.filePicker:
        return Padding(
          padding: const EdgeInsets.only(bottom: constants.mediumPadding),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: constants.mediumPadding,
                vertical: constants.smallPadding),
            child: Align(
                alignment: Alignment.topCenter,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${widget.widgetInfo.widgetLabel}:",
                        style: constants.smallGreyTextStyle,
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(top: constants.mediumPadding),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: constants.formFieldHeight,
                          child: files.isEmpty
                              ? const Image(
                                  image: AssetImage(constants.defaultImage),
                                  fit: BoxFit.fill,
                                )
                              : _getFileThumbnails(),
                        ),
                      ),
                    ])),
          ),
        );
      case constants.geotag:
        List<String> latLng = [];
        if (value.isNotEmpty) {
          latLng = value.split(',');
        }
        return latLng.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: constants.mediumPadding,
                    horizontal: constants.mediumPadding),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${widget.widgetInfo.widgetLabel}:",
                        style: constants.smallGreyTextStyle,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                            0.0, constants.mediumPadding, 0.0, 0.0),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: constants.cameraPlaceholderImageHeight,
                          child: FlutterMap(
                            options: MapOptions(
                              center: LatLng(double.parse(latLng[0]),
                                  double.parse(latLng[1])),
                              zoom: 13,
                              maxZoom: 19,
                              interactiveFlags: InteractiveFlag.none,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                subdomains: ['a', 'b', 'c'],
                              ),
                              MarkerLayer(markers: [
                                Marker(
                                    point: LatLng(double.parse(latLng[0]),
                                        double.parse(latLng[1])),
                                    child: const Icon(
                                      Icons.location_on_rounded,
                                      color: Colors.red,
                                      size: constants.markerIconDimension,
                                    ))
                              ])
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : const SizedBox();
      case constants.geofence:
        return FormFieldGeofenceValuesWidget(
          field: widget.field,
          viewModel: widget.viewModel,
          value: value,
        );
      default:
        return FormRendererUtil.instance.getFormFieldWidget(
            widget.field, widget.viewModel, [],
            formType: constants.previewFormType, value: value);
    }
  }

  getTextLabel() {
    return Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: constants.mediumPadding,
            vertical: constants.smallPadding),
        child: Align(
          alignment: Alignment.centerLeft,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              "${widget.widgetInfo.widgetLabel}:",
              style: constants.smallGreyTextStyle,
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(
                    0.0, constants.smallPadding, 0.0, constants.smallPadding),
                child: Text(
                  value,
                  style: constants.normalBlackTextStyle,
                ))
          ]),
        ));
  }

  _getVideoThumnail() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: images.length,
      itemBuilder: (BuildContext context, int index) {
        if (images[index].isLocal) {
          /// Image is a local image from current form session
          String? path = images[index].path;
          String thumbnailPath = images[index].thumbnailLocalPath;
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
                    onTap: () {
                      AppState.instance
                          .navigateToPreviewScreen(images[index], context);
                    },
                    child: SizedBox(
                      height: constants.cameraPlaceholderImageHeight,
                      child: InkWell(
                        //  onTap: () => _navigateToPreviewScreen(results["videoPath"]),
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
                ],
              ),
            );
          } else {
            return const SizedBox();
          }
        } else {
          /// Image is an online image submitted from an older session
          String? url = images[index].url;
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
                      FormImageFieldWidgetMedia media = FormImageFieldWidgetMedia(false, '', null, url);
                      NavigationUtil.instance
                          .navigateToImagePreviewScreen(context, media);
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

  _getImageThumbnails() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: images.length,
      itemBuilder: (BuildContext context, int index) {
        if (images[index].isLocal) {
          /// Image is a local image from current form session
          String? path = images[index].path;
          if (path != null && path.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.only(right: constants.mediumPadding),
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  InkWell(
                    onTap: () {
                      FormImageFieldWidgetMedia media = FormImageFieldWidgetMedia(false, '', path.toString(), null);
                      NavigationUtil.instance.navigateToImagePreviewScreen(
                          context, media);
                    },
                    child: SizedBox(
                      height: constants.cameraPlaceholderImageHeight,
                      child: Image.file(
                        File(path),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const SizedBox();
          }
        } else if(images[index].url != null) {
          /// Image is an online image submitted from an older session
          String? url = images[index].url;
          if (url != null && url.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.only(right: constants.mediumPadding),
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  InkWell(
                    onTap: () {
                      FormImageFieldWidgetMedia media = FormImageFieldWidgetMedia(false, '', null, url);
                      NavigationUtil.instance.navigateToImagePreviewScreen(
                          context, media);
                    },
                    child: SizedBox(
                      height: constants.cameraPlaceholderImageHeight,
                      child: Image.network(url),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const SizedBox();
          }
        }else{
          return const SizedBox();
        }
      },
    );
  }

  _getFileThumbnails() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: files.length,
      itemBuilder: (BuildContext context, int index) {
        /// Image is a local image from current form session
        String? path = files[index].path;
        if (path != null && path.isNotEmpty) {
          return InkWell(
            onTap: () {
              _openFile(files[index]);
            },
            child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    0.0, 0.0, constants.smallPadding, 0.0),
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
                              files[index].name.split(".").last),
                          height: constants.mimeTypeImageHeight,
                          width: constants.mimeTypeImageWidth,
                        ),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                                constants.xSmallPadding,
                                constants.xSmallPadding,
                                0.0,
                                0.0),
                            child: Tooltip(
                              message: files[index].name.split(".").first,
                              child: Text(
                                files[index].name.split(".").first,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ))),
          );
        }
        return null;
      },
    );
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
