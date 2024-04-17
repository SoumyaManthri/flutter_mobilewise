import 'dart:io';

import 'package:flutter/material.dart';

import '../../../shared/model/image_preview_arguments.dart';
import '../../../utils/app_state.dart';
import '../../../utils/common_constants.dart' as constants;
import '../../../utils/hex_color.dart';
import '../../../utils/util.dart';

class ImagePreviewScreenWidget extends StatefulWidget {
  const ImagePreviewScreenWidget({Key? key,})
      : super(key: key);

  @override
  State<ImagePreviewScreenWidget> createState() =>
      _ImagePreviewScreenWidgetState();
}

class _ImagePreviewScreenWidgetState extends State<ImagePreviewScreenWidget> {
  @override
  Widget build(BuildContext context) {

    final args = ModalRoute.of(context)!.settings.arguments as ImagePreviewArguments;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: HexColor(AppState.instance.themeModel.secondaryColor),
        ),
        elevation: constants.appBarElevation,
        backgroundColor: HexColor(AppState.instance.themeModel.primaryColor),
      ),
      resizeToAvoidBottomInset: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          args.formImageFieldWidgetMedia.latitude != null ?
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Latitude: "),
                Text("${args.formImageFieldWidgetMedia.latitude}"),
              ],
            ),
          ) : const SizedBox(),
          args.formImageFieldWidgetMedia.longitude != null ?
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Longitude: "),
                Text("${args.formImageFieldWidgetMedia.longitude}"),
              ],
            ),
          ) : const SizedBox(),
          args.formImageFieldWidgetMedia.bearing != null ?
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Bearing: "),
                Text("${args.formImageFieldWidgetMedia.bearing}"),
              ],
            ),
          ) : const SizedBox(),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: args.formImageFieldWidgetMedia.path != null && args.formImageFieldWidgetMedia.path !.isNotEmpty ? Center(
                child: Image.file(
                  File(args.formImageFieldWidgetMedia.path!),
                  errorBuilder: (BuildContext context, Object exception,
                      StackTrace? stackTrace) {
                    Util.instance.logMessage('Image Preview screen',
                        'Image.file failed -- $exception');
                    return const Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Color(constants.formFieldBackgroundColor),
                      ),
                    );
                  },
                ),
              ) : args.formImageFieldWidgetMedia.url != null && args.formImageFieldWidgetMedia.url!.isNotEmpty ? Center(
                child: Image.network(
                  args.formImageFieldWidgetMedia.url!,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child;
                    return constants.blackIndicator;
                  },
                  errorBuilder: (BuildContext context, Object exception,
                      StackTrace? stackTrace) {
                    Util.instance.logMessage('Image Preview screen',
                        'Image.network failed -- $exception');
                    return const Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Color(constants.formFieldBackgroundColor),
                      ),
                    );
                  },
                ),
              ) : const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }
}
