import 'package:json_annotation/json_annotation.dart';

part 'theme_result.g.dart';

@JsonSerializable()
class ThemeResult {
  @JsonKey(name: 'result')
  bool? result;

  @JsonKey(name: 'statusCode')
  int? statusCode;

  @JsonKey(name: 'statusCodeDescription')
  String? statusCodeDescription;

  @JsonKey(name: 'message')
  String? message;

  @JsonKey(name: 'response')
  Response? response;

  ThemeResult(
      {this.result,
      this.statusCode,
      this.statusCodeDescription,
      this.message,
      this.response});

  factory ThemeResult.fromJson(Map<String, dynamic> json) =>
      _$ThemeResultFromJson(json);

  Map<String, dynamic> toJson() => _$ThemeResultToJson(this);
}

@JsonSerializable()
class Response {
  ThemeDetails theme;

  Response({required this.theme});

  factory Response.fromJson(Map<String, dynamic> json) =>
      _$ResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ResponseToJson(this);
}

@JsonSerializable()
class ThemeDetails {
  @JsonKey(name: 'theme_id')
  String themeId;

  @JsonKey(name: 'theme_name')
  String themeName;

  @JsonKey(name: 'primary_color')
  String primaryColor;

  @JsonKey(name: 'secondary_color')
  String secondaryColor;

  @JsonKey(name: 'background_color')
  String backgroundColor;

  @JsonKey(name: 'text_color')
  String textColor;

  @JsonKey(name: 'font_heading')
  String fontHeading;

  @JsonKey(name: 'font_body')
  String fontBody;

  @JsonKey(name: 'theme_version')
  int themeVersion;

  ThemeDetails(
      {required this.themeId,
      required this.themeName,
      required this.primaryColor,
      required this.secondaryColor,
      required this.backgroundColor,
      required this.textColor,
      required this.fontHeading,
      required this.fontBody,
      required this.themeVersion});

  factory ThemeDetails.fromJson(Map<String, dynamic> json) =>
      _$ThemeDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$ThemeDetailsToJson(this);
}
