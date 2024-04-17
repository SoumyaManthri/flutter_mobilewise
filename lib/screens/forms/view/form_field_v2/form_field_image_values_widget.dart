import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_mobilewise/screens/forms/view/form_field_v2/video_preview_screen.dart';

import '../../../../shared/model/framework_form.dart';
import '../../../../utils/app_state.dart';
import '../../../../utils/hex_color.dart';
import '../../../../utils/navigation_util.dart';
import '../../model/form_image_field_widget_media.dart';
import '../../view_model/form_view_model.dart';
import '../../../../utils/common_constants.dart' as constants;

class FormFieldImageValuesWidget extends StatefulWidget {
  const FormFieldImageValuesWidget({
    Key? key,
    required this.field,
    required this.viewModel,
    this.value,
  }) : super(key: key);

  final FrameworkFormField field;
  final FormViewModel viewModel;
  final String? value;

  @override
  State<FormFieldImageValuesWidget> createState() => _FormFieldImageValuesWidgetState();
}

class _FormFieldImageValuesWidgetState extends State<FormFieldImageValuesWidget> {
  List<String?> imageUrls = [];
  List<FormImageFieldWidgetMedia> mediaWidgetList = [];
  String uploadType = '';


  @override
  void initState() {
    if (widget.field.additionalConfig.uploadType != null &&
        widget.field.additionalConfig.uploadType!.isNotEmpty) {
      uploadType = widget.field.additionalConfig.uploadType!;
    }
    // TODO: implement initState
    super.initState();
    getValue();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: _view(),
    );
  }

  getValue(){
    List<dynamic>? jsonList = widget.viewModel.dataListSelected?.dataMap?[widget.field.defaultValue]?.value;
    List<FormImageFieldWidgetMedia>? mediaList = jsonList
        ?.map((json) => FormImageFieldWidgetMedia.fromJson(json))
        .toList();
    if (mediaList != null) {
      imageUrls = mediaList.map((media) => media.url).where((url) => url != null).toList();
      mediaWidgetList = mediaList;
    }
  }

  _view() {
    return Padding(
      padding: const EdgeInsets.all(constants.mediumPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: widget.viewModel.getAlignment('left'),
            child: Text(
              '${widget.field.label}: ',
              style: constants.smallGreyTextStyle,
            ),
          ),
          Align(
            alignment: widget.viewModel.getAlignment('left'),
            child: Padding(
              padding:
              const EdgeInsets.only(top: constants.mediumPadding),
              child: imageUrls.isEmpty
                  ? Text(
                constants.attachmentsNotAvailableMsg,
                style: constants.normalBlackTextStyle,
              )
                  : SizedBox(
                width: MediaQuery.of(context).size.width,
                height:uploadType == constants.videoUpload ?
                constants.fileThumbnailHeight:
                constants.cameraPlaceholderImageHeight,
                child:
                uploadType == constants.videoUpload ? _getVideoThumnail():_getImageThumbnails(),
              ),
            ),
          )
        ],
      )
    );
  }

  _getImageThumbnails() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: imageUrls.length,
      itemBuilder: (BuildContext context, int index) {
        String? url = imageUrls[index];
        if (url != null && url.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.only(right: constants.mediumPadding),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                InkWell(
                  onTap: () {
                    NavigationUtil.instance
                        .navigateToImagePreviewScreen(context, mediaWidgetList[index]);
                  },
                  child: SizedBox(
                    height: constants.cameraPlaceholderImageHeight,
                    child: Image.network(
                      url,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                              color: HexColor(AppState.instance.themeModel.primaryColor),
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                            backgroundColor: const Color(constants.greySeparatorColor)
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return null;
      },
    );
  }

  _getVideoThumnail() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: imageUrls.length,
      itemBuilder: (BuildContext context, int index) {
          /// Image is an online image submitted from an older session
          String? videoPath =  mediaWidgetList[index].url;
          String? thumbnailPath = mediaWidgetList[index].thumbnailUrl;
          if (videoPath != null && videoPath.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(
                0.0,
                0.0,
                constants.mediumPadding,
                0.0,
              ),
              child: InkWell(
                onTap: (){
                  _navigateToPreviewScreen(mediaWidgetList[index]);
                },
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    SizedBox(
                      height: 80,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          thumbnailPath!,
                          fit: BoxFit.fill,
                          height: 70,
                          width: 80,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                  color: HexColor(AppState.instance.themeModel.primaryColor),
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                      : null,
                                  backgroundColor: const Color(constants.greySeparatorColor)
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
            );
          } else {
            return const SizedBox();
          }
      },
    );
  }


  _navigateToPreviewScreen(FormImageFieldWidgetMedia formImageFieldWidgetMedia) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              VideoPreviewScreen(
                formImageFieldWidgetMedia: formImageFieldWidgetMedia,
              ),
        ),
      );
    });
  }
}
