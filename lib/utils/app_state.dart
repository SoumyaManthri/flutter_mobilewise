import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:event_bus/event_bus.dart';
import 'package:flutter_mobilewise/model/theme_model/theme_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_mobilewise/screens/forms/model/form_image_field_widget_media.dart';
import 'package:flutter_mobilewise/shared/model/form_widget_data.dart';
import 'package:flutter_mobilewise/utils/hex_color.dart';
import 'package:flutter_mobilewise/utils/secured_storage_util.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../screens/forms/view/form_field_v2/video_preview_screen.dart';
import '../screens/home/model/user_permissions_model.dart';
import '../screens/login/model/jwt_model.dart';
import '../shared/event/app_events.dart';
import '../shared/model/framework_form.dart';
import '../../../utils/common_constants.dart' as constants;

class AppState {
  static AppState? _instance;

  AppState._();

  static AppState get instance => _instance ??= AppState._();

  EventBus eventBus = EventBus();

  late String userId;
  late String username;
  late String? jwtTokenString;
  late String? csrfTokenString;
  late JWTModel jwtToken;
  late String? hiveEncryptionKey;
  late String? lastLogin;
  UserPermissionsModel? userPermissions;
  late ThemeDetails themeModel = ThemeDetails(
      themeId: "themeId",
      themeName: "themeName",
      primaryColor: "FFFBD002",
      secondaryColor: "FFFBD002",
      backgroundColor: "FFFBD002",
      textColor: "FFFBD002",
      fontHeading: "FFFBD002",
      fontBody: "fontBody",
      themeVersion: 1);

  /// This variable is initialized based on the flavor of the app that is running
  /// Possible values -
  /// 1. DEV
  /// 2. QA
  /// 3. PROD
  late String? environment;

  /// The forms list received from the server, used to create the form screens
  List<FrameworkForm> formsList = [];
  Map<String, String> formsTypesWithKey = {};

  /// The current user location
  Position? currentUserLocation;

  /// User location stream
  StreamSubscription<Position>? positionStream;

  /// Flag for app background sync
  bool isSyncInProgress = false;

  /// Get current user location
  getCurrentUserLocation() async{
    currentUserLocation = await Geolocator.getCurrentPosition();
  }

  /// Tracking user location
  startTrackingUserLocation() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0,
    );
    positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
            (Position? position) {
          currentUserLocation = position;
    });
  }

  /// Stop Tracking user location
  stopTrackingUserLocation() {
    if (positionStream != null) {
      positionStream!.cancel();
    }
  }

  /// 1. This map stores all the key value pairs of the data entered by a user
  /// while they fill the form.
  /// 2. This is not the map that is submitted to the backend when the user tries
  /// to submit the form.
  /// 3. When the user reaches a preview form, we create a new map, that contains
  /// all the user entered data based on the choices they make to traverse the
  /// form based on the decision nodes.
  /// Example - For the 'Report Failure' form, the user can select a 'Thermal
  /// Event' as the discrepancy, and fill the data for it. But at some point,
  /// if the user goes back and changes the discrepancy to 'Freight Damage', then
  /// we will have to clear some of the fields for 'Thermal Event'.
  final Map<String, dynamic> _formTempMap = {};
  final Map<String, FormWidgetData> _formTempWidgetMap = {};

  /// Getter for formTempMap
  Map<String, dynamic> get formTempMap => _formTempMap;

  Map<String, FormWidgetData> get formTempWidgetMap => _formTempWidgetMap;

  late int textHexColor;


  /// Adding a key and value pair to formTempMap
  addToFormTempMap(String key, dynamic value) {
    _formTempMap[key] = value;
    eventBus.fire(FormTempMapChangeEvent());
  }

  /// Clearing formTempMap
  clearFormTempMap() {
    _formTempMap.clear();
  }

  /// Remove key value pair from tempMap
  removeFromFormTempMap(String key) {
    _formTempMap.remove(key);
    eventBus.fire(FormTempMapChangeEvent());
  }

  /// Adding a key and value pair to formTempMap
  addToFormTempWidgetMap(String key,  FrameworkFormField field, String entity) {
    _formTempWidgetMap[key] = FormWidgetData(field, entity);
    // eventBus.fire(FormTempMapChangeEvent());
  }

  /// Clearing formTempMap
  clearFormTempWidgetMap() {
    _formTempWidgetMap.clear();
  }

  /// Remove key value pair from tempMap
  removeFromTempWidgetMap(String key) {
    _formTempWidgetMap.remove(key);
    // eventBus.fire(FormTempMapChangeEvent());
  }

  setTheme(ThemeDetails themeModel) async {
    this.themeModel = themeModel;
    await SecuredStorageUtil.instance
        .writeSecureData(constants.theme, jsonEncode(themeModel.toJson()));
    textHexColor = themeModel.themeName.contains('Dark')? constants.darkThemetextColor:constants.lightThemeTextColor;
  }

  toastMessage(String message){
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: HexColor(AppState.instance.themeModel.primaryColor),
        textColor: HexColor(AppState.instance.themeModel.textColor),
        fontSize: 16.0
    );
  }

  navigateToPreviewScreen(FormImageFieldWidgetMedia formImageFieldWidgetMedia, BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPreviewScreen(
            formImageFieldWidgetMedia: formImageFieldWidgetMedia,
          ),
        ),
      );
    });
  }


  Future<Uint8List?> generateThumbnailForLocal(String videoPath) async {
    return VideoThumbnail.thumbnailData(
      video: videoPath,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 128,
      quality: 100,
    );
  }

  Future<bool> saveThumbnailToFile(Uint8List? thumbnailData, String filePath) async {
    if (thumbnailData != null) {
      File thumbnailFile = File(filePath);
      await thumbnailFile.writeAsBytes(thumbnailData);
      print('Thumbnail saved to: ${thumbnailFile.path}');
      return true;
    } else {
      print('Error: Thumbnail data is null');
      return false;
    }
  }
}