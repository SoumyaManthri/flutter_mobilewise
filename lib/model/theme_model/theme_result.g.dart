// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThemeResult _$ThemeResultFromJson(Map<String, dynamic> json) => ThemeResult(
      result: json['result'] as bool?,
      statusCode: json['statusCode'] as int?,
      statusCodeDescription: json['statusCodeDescription'] as String?,
      message: json['message'] as String?,
      response: json['response'] == null
          ? null
          : Response.fromJson(json['response'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ThemeResultToJson(ThemeResult instance) =>
    <String, dynamic>{
      'result': instance.result,
      'statusCode': instance.statusCode,
      'statusCodeDescription': instance.statusCodeDescription,
      'message': instance.message,
      'response': instance.response,
    };

Response _$ResponseFromJson(Map<String, dynamic> json) => Response(
      theme: ThemeDetails.fromJson(json['theme'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ResponseToJson(Response instance) => <String, dynamic>{
      'theme': instance.theme,
    };

ThemeDetails _$ThemeDetailsFromJson(Map<String, dynamic> json) => ThemeDetails(
      themeId: json['theme_id'] as String,
      themeName: json['theme_name'] as String,
      primaryColor: json['primary_color'] as String,
      secondaryColor: json['secondary_color'] as String,
      backgroundColor: json['background_color'] as String,
      textColor: json['text_color'] as String,
      fontHeading: json['font_heading'] as String,
      fontBody: json['font_body'] as String,
      themeVersion: json['theme_version'] as int,
    );

Map<String, dynamic> _$ThemeDetailsToJson(ThemeDetails instance) =>
    <String, dynamic>{
      'theme_id': instance.themeId,
      'theme_name': instance.themeName,
      'primary_color': instance.primaryColor,
      'secondary_color': instance.secondaryColor,
      'background_color': instance.backgroundColor,
      'text_color': instance.textColor,
      'font_heading': instance.fontHeading,
      'font_body': instance.fontBody,
      'theme_version': instance.themeVersion,
    };
