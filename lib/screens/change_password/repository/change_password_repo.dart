import 'package:flutter/material.dart';
import '../../../domain/network/api_service.dart';
import '../../../shared/model/common_api_response.dart';
import '../../../utils/app_state.dart';
import '../model/change_password_model.dart';
import 'package:dio/dio.dart' as dio;
import '../../../utils/common_constants.dart' as constants;

/// Abstract class for the change password repository
abstract class ChangePasswordRepository {
  Future<CommonApiResponse> logout(String token);

  Future<ChangePasswordResponse?> changePassword(String newPassword, BuildContext context);
}

class ChangePasswordRepositoryImpl extends ChangePasswordRepository {

  @override
  Future<ChangePasswordResponse?> changePassword(String newPassword, BuildContext context) async {

    Map<String, String> tokenHeaders = {
      constants.authorization: 'Bearer ${AppState.instance.jwtTokenString!}',
    constants.accept: constants.headerJson,
    constants.headerContentType: constants.headerJson,
    };
    final client = ApiService.getClient(constants.authBaseUrl, tokenHeaders);

    final Map<String, dynamic> apiBodyData = {
      'type': 'password',
      'value': newPassword,
      'userId': AppState.instance.jwtToken.sub,
      'temporary': false
    };

    ChangePasswordResponse? response;
    try {
      response = await client.changePassword(apiBodyData);
        } on dio.DioException catch (e) {
      print(e.response);
    }
    return response;
  }

  @override
  Future<CommonApiResponse> logout(String token) {
    // TODO: implement logout
    throw UnimplementedError();
  }
}
