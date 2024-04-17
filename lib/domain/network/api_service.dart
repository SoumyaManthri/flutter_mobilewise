import 'package:dio/dio.dart';
import 'package:flutter_mobilewise/model/theme_model/theme_result.dart';
import 'package:flutter_mobilewise/screens/change_password/model/change_password_model.dart';
import 'package:retrofit/http.dart';

import '../../shared/model/form_model.dart';
import '../../utils/common_constants.dart' as constants;

part 'api_service.g.dart';

@RestApi()
abstract class ApiService {
  static String token = '';

  static getClient(String baseUrl, [Map<String, String>? headers] ) {
    ApiService client = ApiService(Dio(BaseOptions(
        contentType: "application/json", baseUrl: baseUrl, headers: headers)));

    return client;
  }

  factory ApiService(Dio dio) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print("::: Api Url : ${options.uri} ${options.data}");
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print("Response : ${response.requestOptions.uri} ${response.data}");

        return handler.next(response);
      },
      onError: (DioException e, handler) {
        if (e.response != null) {
          print("Response error : ${e.response}");
        }
        return handler.next(e);
      },
    ));

    return _ApiService(dio);
  }

  @PUT('/${constants.changePasswordEndpoint}')
  Future<ChangePasswordResponse> changePassword(
      @Body() Map<String, dynamic> body);

  @GET('${constants.themeEndpoint}/${constants.appId}')
  Future<ThemeResult> fetchTheme();

  @GET('${constants.applicationPagesEndpoint}/${constants.appId}')
  Future<List<PageInfo>> getForms();
}
