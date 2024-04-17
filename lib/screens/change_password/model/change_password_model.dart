import 'package:json_annotation/json_annotation.dart';

part 'change_password_model.g.dart';

@JsonSerializable()
class ChangePasswordResponse {
  @JsonKey(name: 'result')
  final bool result;

  @JsonKey(name: 'statusCode')
  final int statusCode;

  @JsonKey(name: 'statusCodeDescription')
  final String statusCodeDescription;

  @JsonKey(name: 'message')
  final String? message;

  ChangePasswordResponse(this.result, this.statusCode, this.statusCodeDescription, this.message);

  factory ChangePasswordResponse.fromJson(Map<String, dynamic> json) =>
      _$ChangePasswordResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ChangePasswordResponseToJson(this);
}
