import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../model/form_image_field_widget_media.dart';

class VideoPreviewWidget extends StatefulWidget {
  final FormImageFieldWidgetMedia formImageFieldWidgetMedia;
  const VideoPreviewWidget({super.key,
    required this.formImageFieldWidgetMedia,
  });

  @override
  _VideoPreviewWidgetState createState() => _VideoPreviewWidgetState();
}

class _VideoPreviewWidgetState extends State<VideoPreviewWidget> {
  late VideoPlayerController videoPlayerController;
  late ChewieController chewieController;
  late Chewie playerWidget;

  @override
  void initState() {
    // Create and store the VideoPlayerController. The VideoPlayerController
    // offers several different constructors to play videos from assets, files,
    // or the internet.
    String? localVideoPath = widget.formImageFieldWidgetMedia.path;
    String? videourl = widget.formImageFieldWidgetMedia.url;
    if (localVideoPath != null && localVideoPath.isNotEmpty) {
      videoPlayerController =
          VideoPlayerController.file(File(localVideoPath));

      chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        aspectRatio: videoPlayerController.value.aspectRatio,
        autoPlay: true,
        looping: false,
      );
      playerWidget = Chewie(
        controller: chewieController,
      );
    } else if (videourl != null && videourl.isNotEmpty) {
      videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videourl));
      chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        aspectRatio:videoPlayerController.value.aspectRatio,
        autoPlay: true,
        looping: true,
      );
      playerWidget = Chewie(
        controller: chewieController,
      );

    }
    super.initState();
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        widget.formImageFieldWidgetMedia.latitude != null ?
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Latitude: "),
              Text("${widget.formImageFieldWidgetMedia.latitude}"),
            ],
          ),
        ) : const SizedBox(),
        widget.formImageFieldWidgetMedia.longitude != null ?
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Longitude: "),
              Text("${widget.formImageFieldWidgetMedia.longitude}"),
            ],
          ),
        ) : const SizedBox(),
        widget.formImageFieldWidgetMedia.bearing != null ?
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Bearing: "),
              Text("${widget.formImageFieldWidgetMedia.bearing}"),
            ],
          ),
        ) : const SizedBox(),
        Container(
    height: 500,
    alignment: Alignment.center,
    child: playerWidget,
    ),]
    );
  }
}
