import 'package:flutter/material.dart';
import 'package:flutter_mobilewise/screens/forms/view/form_field_v2/video_preview_widget.dart';

import '../../../../utils/app_state.dart';
import '../../../../utils/hex_color.dart';
import '../../../../utils/common_constants.dart' as constants;
import '../../model/form_image_field_widget_media.dart';

class VideoPreviewScreen extends StatelessWidget {
  final FormImageFieldWidgetMedia formImageFieldWidgetMedia;

  const VideoPreviewScreen({super.key,
    required this.formImageFieldWidgetMedia
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: HexColor(AppState.instance.themeModel.secondaryColor),
        ),
        elevation: constants.appBarElevation,
        backgroundColor: HexColor(AppState.instance.themeModel.primaryColor),
        title: Center(child: Text(constants.videoPreview)),
      ),
      resizeToAvoidBottomInset: false,
      body: VideoPreviewWidget(
        formImageFieldWidgetMedia: formImageFieldWidgetMedia,
      ),
    );
  }
}
