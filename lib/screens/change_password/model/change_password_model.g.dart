// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_password_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChangePasswordResponse _$ChangePasswordResponseFromJson(
        Map<String, dynamic> json) =>
    ChangePasswordResponse(
      json['result'] as bool,
      json['statusCode'] as int,
      json['statusCodeDescription'] as String,
      json['message'] as String?,
    );

Map<String, dynamic> _$ChangePasswordResponseToJson(
        ChangePasswordResponse instance) =>
    <String, dynamic>{
      'result': instance.result,
      'statusCode': instance.statusCode,
      'statusCodeDescription': instance.statusCodeDescription,
      'message': instance.message,
    };
