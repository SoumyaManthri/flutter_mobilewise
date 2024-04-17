class FormImageFieldWidgetMedia {
  bool isLocal;
  String name;
  String? path;
  String? url;
  String? thumbnailLocalPath;
  String? thumbnailUrl;
  double? bearing;
  double? latitude;
  double? longitude;

  FormImageFieldWidgetMedia(this.isLocal, this.name, this.path, this.url, {this.thumbnailLocalPath, this.thumbnailUrl, this.bearing, this.latitude, this.longitude});

  factory FormImageFieldWidgetMedia.fromJson(Map<String, dynamic> json) {
    return FormImageFieldWidgetMedia(
      false,
      json['name'] ?? '',
      '',
      json['url'],
      thumbnailLocalPath: '',
      thumbnailUrl: json['thumbnailUrl'],
      bearing: json['bearing']?.toDouble(),
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
      'thumbnailLocalPath': thumbnailLocalPath,
      'thumbnailUrl': thumbnailUrl,
      'bearing': bearing,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}