import 'dart:collection';
import 'dart:convert';
import 'dart:developer' as developer;
//import 'dart:html';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobilewise/shared/model/form_model.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:recase/recase.dart';

import '../../../environments/dev_env.dart';
import '../../../environments/prod_env.dart';
import '../../../environments/qa_env.dart';
import '../../../utils/app_state.dart';
import '../../../utils/common_constants.dart' as constants;
import '../../../utils/navigation_util.dart';
import '../../../utils/secured_storage_util.dart';
import '../../../utils/shared_preference_util.dart';
import '../aws_s3_upload/enum/acl.dart';
import '../shared/model/framework_form.dart';

class Util {
  static Util? _instance;

  Util._();

  static Util get instance => _instance ??= Util._();

  /// Dropdown Overlays queue to store all the created overlays, because they are
  /// independent floating widgets and can be access form anywhere.
  Queue<OverlayEntry> dropdownOverlayList = Queue<OverlayEntry>();

  Future<String> loadAsset(String fileName) async {
    return await rootBundle.loadString(fileName);
  }

  getDisplayDate(DateTime selectedDate) {
    return DateFormat.yMMMd().format(selectedDate);
  }

  setDynamicDateFormat(DateTime selectedDate, String dateFormat) {
    if(dateFormat.isNotEmpty) {
      return DateFormat(dateFormat).format(selectedDate);
    }else{
      return DateFormat.yMMMd().format(selectedDate);
    }
  }

  /// Converting string to base64 format
  getConvertedBase64String(String text) {
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String encoded = stringToBase64.encode(text);
    return encoded;
  }

  /// Get deviceID of Android and iOS devices
  /*getDeviceId() async {
    if (Platform.isIOS) {
      const platform = MethodChannel(constants.iosIdChannel);
      var uniqueIOSId = await platform.invokeMethod(constants.getUniqueIdForIOS);// unique ID on iOS
      return uniqueIOSId;
    } else if (Platform.isAndroid) {
      const androidIdPlugin = AndroidId();
      final String? androidId = await androidIdPlugin.getId();
      return androidId;  // unique ID on Android
    }
  }*/

  addOverlay(OverlayEntry overlayEntry ) {
    dropdownOverlayList.add(overlayEntry);
  }

  /// To remove all the dropdown overlays when touched outside anywhere on screen.
  void removeAllDropDownOverlays() {
    while (dropdownOverlayList.isNotEmpty) {
      OverlayEntry overlayEntry = dropdownOverlayList.removeLast();
      overlayEntry.remove();
    }
  }


  /// Token validation
  bool validateToken(String token) {
    /// Split into 3 parts with . delimiter
    if (token != null && token.isNotEmpty) {
      List parts = token.split(".");
      if (parts.length != 3) {
        return false;
      } else {
        if (parts[1].toString().isNotEmpty) {
          try {
            json.decode(decodeBase64(parts[1]));
            return true;
          } catch (UnsupportedEncodingException) {
            return false;
          }
        } else {
          return false;
        }
      }
    } else {
      return false;
    }
  }
  showPermissionsAlert(BuildContext context, {String? permissionName}) async{
    var result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () {
              Navigator.pop(context, true);
              return Future.value(true);
            },
            child: AlertDialog(
                title: Text("Mandatory Permissions Denied", style: constants.largeBlackTextStyle),
                content: Text(
                  "Please grant ${permissionName != null ? "${permissionName.split(".")[1].titleCase} permission" : "requested permissions"} for app functionality through settings app",
                  style: constants.lMediumBlackTextStyle,
                ),
                actions: [
                  TextButton(
                      child: Text(
                        "Okay",
                      ),
                      onPressed: () async{
                        Navigator.pop(context, true);
                      }
                  )
                ]
            ),
          );
        }
    );
    return result;
  }

  Future<bool> checkPermissionStatus(BuildContext context, Permission permission) async{
    print(permission.toString());
    PermissionStatus? permissionStatus = await permission.request();
    if(permissionStatus.isGranted) {
      return true;
    } else if (permissionStatus == PermissionStatus.denied) {
      Map<Permission, PermissionStatus> statuses = await [
        permission,
      ].request();
      PermissionStatus? newPermissionStatus = statuses[permission];
      if(newPermissionStatus == PermissionStatus.granted) {
        return true;
      }
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      bool? settingsDone = await showPermissionsAlert(context, permissionName: permission.toString());
      if(settingsDone != null) {
        PermissionStatus? latestPermissionStatus = await permission.status;
        if(latestPermissionStatus.isGranted) {
          return true;
        } else {
          return false;
        }
      }
    }
    return false;
  }

  String decodeBase64(String strDecode) {
    if (strDecode.isNotEmpty) {
      const Base64Codec base64Url = Base64Codec.urlSafe();
      String s = base64.normalize(strDecode);
      Uint8List decodedint = base64Url.decode(s);
      String decodedString = utf8.decode(decodedint);
      return decodedString;
    } else {
      return '';
    }
  }

  logMessage(String title, String message) {
    developer.log(
      'MobileWise Log',
      name: title,
      error: message,
    );
  }

  Future<String> getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    return '$version+$buildNumber';
  }

  /// This method accepts a string timestamp (milliseconds since epoch (UTC)),
  /// and converts it into local date and time in the 24 hour format
  String getLocalDateTimeIn24(String timestamp) {
    int millis = int.parse(timestamp);
    DateTime dt = DateTime.fromMillisecondsSinceEpoch(millis);
    DateTime localDt = dt.toLocal();
    return DateFormat('dd/MM/yyyy, HH:mm').format(localDt);
  }

  /// This method accepts a string timestamp (milliseconds since epoch (UTC)),
  /// and converts it into local date
  String getLocalDate(String timestamp) {
    int millis = int.parse(timestamp);
    DateTime dt = DateTime.fromMillisecondsSinceEpoch(millis);
    DateTime localDt = dt.toLocal();
    return DateFormat('dd/MM/yyyy').format(localDt);
  }

  /// Returns app name based on build flavor
  getAppNameBasedOnFlavor() {
    return constants.appNameProd;
    /*if(AppState.instance.environment != null) {
      if(AppState.instance.environment  == constants.flavorNameDev) {
        return constants.appNameDev;
      } else if(AppState.instance.environment  == constants.flavorNameQa) {
        return constants.appNameQa;
      } else {
        return constants.appNameProd;
      }
    } else {
      return constants.appNameProd;
    }*/
  }

  /// Initialize base URLs based on build flavor (using environment files)
  initBaseUrls(){
    if(AppState.instance.environment != null) {
      if(AppState.instance.environment  == constants.flavorNameDev) {
        constants.baseUrl = DevEnv.baseUrl;
        constants.authBaseUrl = DevEnv.authBaseUrl;
        constants.accessKey = DevEnv.accessKey;
        constants.secretKey = DevEnv.secretKey;
        constants.bucket = DevEnv.bucket;
        constants.region = DevEnv.region;

      } else if(AppState.instance.environment  == constants.flavorNameQa) {
        constants.baseUrl = QaEnv.baseUrl;
        constants.authBaseUrl = QaEnv.authBaseUrl;
        constants.accessKey = QaEnv.accessKey;
        constants.secretKey = QaEnv.secretKey;
        constants.bucket = QaEnv.bucket;
        constants.region = QaEnv.region;
      } else {
        constants.baseUrl = ProdEnv.baseUrl;
        constants.authBaseUrl = ProdEnv.authBaseUrl;
        constants.accessKey = ProdEnv.accessKey;
        constants.secretKey = ProdEnv.secretKey;
        constants.bucket = ProdEnv.bucket;
        constants.region = ProdEnv.region;
      }
    } else {
      constants.baseUrl = ProdEnv.baseUrl;
      constants.authBaseUrl = ProdEnv.authBaseUrl;
      constants.accessKey = ProdEnv.accessKey;
      constants.secretKey = ProdEnv.secretKey;
      constants.bucket = ProdEnv.bucket;
      constants.region = ProdEnv.region;
    }
  }

  /// Token expired, redirect to login screen
  redirectToLoginBecauseOfTokenExpiry(BuildContext context) async {
    await _setLogoutSharedPreferences();
    AppState.instance.userId = '';
    AppState.instance.username = '';
    AppState.instance.jwtTokenString = '';

    /// Navigate to login screen
    NavigationUtil.instance.navigateToLoginScreen(context);
  }

  /// Setting the shared preferences on logout
  _setLogoutSharedPreferences() async {
    await SharedPreferenceUtil.instance.setPreferenceValue(
        constants.preferenceIsLoggedIn, false, constants.preferenceTypeBool);
    await SecuredStorageUtil.instance
        .writeSecureData(constants.preferenceUserId, '');
    await SecuredStorageUtil.instance
        .writeSecureData(constants.preferenceUsername, '');
    await SecuredStorageUtil.instance
        .writeSecureData(constants.preferenceJwtModelString, '');
    await SecuredStorageUtil.instance
        .writeSecureData(constants.preferenceLastLogin, '');
  }

  getImageForMimeType(String? mimeType) {
    if(mimeType == "doc" || mimeType == "docx") {
      return "assets/images/word_doc.png";
    } else if(mimeType == "pdf") {
      return "assets/images/pdf_file.png";
    } else if (mimeType == "xlsx" || mimeType == "xls") {
      return "assets/images/excel_file.png";
    } else if (mimeType == "ppt" || mimeType == "pptx") {
      return "assets/images/ppt_file.png";
    } else if (mimeType == "png" || mimeType == "jpg" || mimeType == "jpeg") {
      return "assets/images/image_file.png";
    } else if (mimeType == "mp3") {
      return "assets/images/audio_file.png";
    } else if (mimeType == "mp4") {
      return "assets/images/video_file.png";
    } else {
      return "assets/images/default_file.png";
    }
  }

  showSnackBar(BuildContext context, String snackBarContent) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(snackBarContent)));
  }


  //todo remove this method after imaplementation of Dashboard page json
  double getTopMargin(FrameworkFormStyle? style){
    if (style != null && style.marginTop > 0) {
      return style.marginTop.toDouble();
    }
    return 0;
  }

  double getTopMarginFromWidgetInfo(WidgetConfigStyle? style){
    if (style != null && style.marginTop != null) {
      double margin = double.parse(style.marginTop!.replaceAll("px", ""));
      return margin;
    }
    return 0;
  }

  String aclToString(ACL acl) {
    switch (acl) {
      case ACL.private:
        return 'private';
      case ACL.public_read:
        return 'public-read';
      case ACL.public_read_write:
        return 'public-read-write';
      case ACL.aws_exec_read:
        return 'aws-exec-read';
      case ACL.authenticated_read:
        return 'authenticated-read';
      case ACL.bucket_owner_read:
        return 'bucket-owner-read';
      case ACL.bucket_owner_full_control:
        return 'bucket-owner-full-control';
      case ACL.log_delivery_write:
        return 'log-delivery-write';
    }
  }

  Future downloadFile(String url) async{
    var httpClient = HttpClient();
    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    return bytes;
  }

  bool isJSON(string) {
    try {
      json.decode(string);
    } catch (e) {
      return false;
    }
    return true;
  }

  num? toNum(String str) {
    if (isInteger(str)) {
      return int.parse(str);
    } else if (isDouble(str)) {
      return double.parse(str);
    } else {
      return null; // Return null if the string doesn't represent a valid integer or double
    }
  }

  bool isInteger(String str) {
    try {
      int.parse(str);
      return true;
    } catch (e) {
      return false;
    }
  }

  bool isDouble(String str) {
    try {
      double.parse(str);
      return true;
    } catch (e) {
      return false;
    }
  }

}
enum SupportState {
  unknown,
  supported,
  unsupported,
}
