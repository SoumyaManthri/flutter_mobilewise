import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class GenerateThumbnailForLocalVideo extends StatefulWidget {
  const GenerateThumbnailForLocalVideo({
    Key? key,
    required this.isLocal,
    required this.path,
  }) : super(key: key);

  final bool isLocal;
  final String path;
  @override
  _MyThumbnailWidgetState createState() => _MyThumbnailWidgetState();
}

class _MyThumbnailWidgetState extends State<GenerateThumbnailForLocalVideo> {
  late Future<Uint8List?> thumbnailData;
  String path = '';

  @override
  void initState() {
    super.initState();
    path = widget.path;
    if(widget.isLocal) {
      thumbnailData = generateThumbnailForLocal();
    }
  }

  Future<Uint8List?> generateThumbnailForLocal() async {
    return VideoThumbnail.thumbnailData(
      video: path,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 128,
      quality: 100,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<Uint8List?>(
        future: thumbnailData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return Image.memory(snapshot.data!);
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}