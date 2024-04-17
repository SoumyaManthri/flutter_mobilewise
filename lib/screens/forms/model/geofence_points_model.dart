class GeofencePointsModel {
  double latitude;
  double longitude;
  GeofencePointsModel({required this.latitude, required this.longitude});

  factory GeofencePointsModel.fromJson(Map<String, dynamic> json) {
    return GeofencePointsModel(
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
  };
}