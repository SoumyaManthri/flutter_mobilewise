import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../shared/model/framework_form.dart';
import '../../../../shared/model/geofence_arguments.dart';
import '../../../../utils/app_state.dart';
import '../../../../utils/hex_color.dart';
import '../../../../utils/map_util.dart';
import '../../../../utils/util.dart';
import '../../../../utils/validation_util.dart';
import '../../model/geofence_points_model.dart';
import '../../view_model/form_view_model.dart';
import '../../../../utils/common_constants.dart' as constants;
import '../form_field_views/full_screen_geofence_widget.dart';
class FormGeofenceFieldWidget extends StatefulWidget {
  const FormGeofenceFieldWidget({
    Key? key,
    required this.field,
    required this.viewModel,
  }) : super(key: key);

  final FrameworkFormField field;
  final FormViewModel viewModel;

  @override
  State<FormGeofenceFieldWidget> createState() => _FormGeofenceFieldWidgetState();
}

class _FormGeofenceFieldWidgetState extends State<FormGeofenceFieldWidget> {
  MapController mapController = MapController();
  double lat = -1;
  double lng = -1;
  List<Marker> mapMarkers = [];
  LatLng mapCenter = const LatLng(0, 0);
  String geofencingMode = "";
  String geometryType = "";
  List<LatLng> selectedPoints = [];
  List<Marker> selectedPointMarkers = [];
  List<Polyline> polylines = [];
  List<Polygon> polygons = [];
  List<Widget> mapLayers = [];

  @override
  void initState() {
    super.initState();
    if (widget.field.isEditable &&
        AppState.instance.formTempMap.containsKey(widget.field.key)) {
      /// Dropped location exists in the formTempMap (user has dropped it already)
      String value = AppState.instance.formTempMap[widget.field.key];
      if (value.isNotEmpty) {
        List<GeofencePointsModel> geofencePoints = [];
        dynamic decodedValue = json.decode(value);
        geofencePoints = (decodedValue as List?)!.map((dynamic e) => GeofencePointsModel.fromJson(e as Map<String, dynamic>)).toList();
        for (int i = 0; i < geofencePoints.length; i++) {
          selectedPoints.add(LatLng(geofencePoints[i].latitude,geofencePoints[i].longitude));
        }
      }
    } else if (widget.viewModel.clickedSubmissionValuesMap
        .containsKey(widget.field.key)) {
      /// Dropped location exists in the formDataListSubmissionMap
      String value =
      widget.viewModel.clickedSubmissionValuesMap[widget.field.key];
      if (value.isNotEmpty) {
        value = value.replaceAll("{", "");
        value = value.replaceAll("}", "");
        value = value.replaceAll("[", "");
        value = value.replaceAll("]", "");
        value = value.replaceAll(" ", "");
        List<String> latLngList = value.split(",");
        for (int i = 0; i < latLngList.length - 1; i+=2) {
          selectedPoints.add(LatLng(double.parse(latLngList[i]),double.parse(latLngList[i+1])));
        }
      }
    } else if (AppState.instance.currentUserLocation != null) {
      if (AppState.instance.currentUserLocation!.latitude != null &&
          AppState.instance.currentUserLocation!.longitude != null) {
        /// Pick current user location
        lat = AppState.instance.currentUserLocation!.latitude!.toDouble();
        lng = AppState.instance.currentUserLocation!.longitude!.toDouble();
      }
    }
    if (lat != -1 && lng != -1 && mapMarkers.isEmpty) {
      mapMarkers.add(Marker(
        point: LatLng(lat, lng),
        child: const Icon(
          Icons.location_on_rounded,
          color: Colors.red,
          size: constants.markerIconDimension,
        ),
      ));
      mapCenter = LatLng(lat, lng);
    }
    initializeMapLayers();
    initializeGeometryType();
    initializeGeofencingMode();
  }

  initializeMapLayers() {
    mapLayers.add(TileLayer(
      urlTemplate:
      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
      subdomains: ['a', 'b', 'c'],
    ));
  }

  initializeGeometryType() {
    if (widget.field.additionalConfig.geofenceShape != null) {
      geometryType = widget.field.additionalConfig.geofenceShape!;
    }
  }

  initializeGeofencingMode() {
    if (widget.field.additionalConfig.geofenceTypes != null) {
      geofencingMode = widget.field.additionalConfig.geofenceTypes!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _view();
  }

  _view() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          0.00,
          Util.instance.getTopMargin(widget.field.style),
          0.00,
          constants.mediumPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: widget.field.label,
              style: widget.field.style != null
                  ? constants.applyStyleV2(
                  bold: widget.field.style!.bold,
                  underline: widget.field.style!.underline,
                  italics: widget.field.style!.italics,
                  color: widget.field.style!.color,
                  size: widget.field.style!.size)
                  : constants.applyStyleV2(),
              children: <TextSpan>[
                // Red * to show if the field is mandatory
                TextSpan(
                  text: ValidationUtil.isMandatory(widget.field.validations) &&
                      widget.field.isEditable
                      ? ' *'
                      : '',
                  style: constants.normalRedTextStyle,
                ),
              ],
            ),
          ),
          const SizedBox(
            height: constants.smallPadding,
          ),
          lat != -1 && lng != -1
              ? Container(
              decoration: borderOutlined(),
              width: MediaQuery.of(context).size.width,
              height: constants.cameraPlaceholderImageHeight,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(
                  Radius.circular(5.0),
                ),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: mapCenter,
                    initialZoom: 13,
                    maxZoom: 19,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                    ),
                    onTap: (tapPosition, latLng) async {
                      if (widget.field.isEditable) {
                        /// Open the full screen geofencing widget
                        GeofenceArguments? ga = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FullScreenGeofenceWidget(
                                latitude: lat,
                                longitude: lng,
                                selectedPoints: selectedPoints,
                                field: widget.field,
                              )),
                        );
                        if (ga != null) {
                          selectedPoints = ga.geofencePoints;
                          setState(() {
                            if (selectedPoints.isNotEmpty) {
                              mapCenter = MapUtil.calculateCentroid(selectedPoints);
                            }
                            selectedPointMarkers.clear();
                            polylines.clear();
                            polygons.clear();
                            mapLayers.clear();
                          });
                          initializeMapLayers();
                          drawAsset();
                        }
                      }
                    },
                  ),
                  mapController: mapController,
                  children: mapLayers,
                ),
              ))
              : const SizedBox(),
        ],
      ),
    );
  }

  Decoration borderOutlined() {
    return BoxDecoration(
      color: Colors.black,
      shape: BoxShape.rectangle,
      borderRadius: const BorderRadius.all(Radius.circular(5)),
      border: Border.all(),
    );
  }

  drawAsset() {
    if(geometryType == constants.geofenceShapeLine) {
      createPolylineAsset();
    } else if (geometryType == constants.geofenceShapePolygon){
      createPolygonAsset();
    }
    createMarker();
  }

  createMarker() {
    setState(() {
      selectedPointMarkers.clear();
      for(int i=0; i < selectedPoints.length; i++) {
        selectedPointMarkers.add(Marker(
          height: 16.0,
          width: 16.0,
          point: selectedPoints[i],
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100.0),
              color: HexColor(
                  AppState.instance.themeModel.primaryColor),
            ),
            child: Center(child: Text(
              "$i",
              style: TextStyle(
                color: HexColor(AppState.instance.themeModel.secondaryColor),
              ),
            )),
          ),
        ));
      }
      mapLayers.add(MarkerLayer(
          markers: selectedPointMarkers
      ));
    });
  }

  createPolylineAsset() {
    setState(() {
      polylines.clear();
      polylines.add(Polyline(
        points: selectedPoints,
        color: HexColor(AppState.instance.themeModel.primaryColor),
        borderStrokeWidth: 3.0,
        borderColor: HexColor(AppState.instance.themeModel.primaryColor),
      ));
      mapLayers.add(PolylineLayer(
        polylines: polylines,
      ));
    });
  }

  createPolygonAsset() {
    setState(() {
      polygons.clear();
      polygons.add(
          Polygon(
            points: selectedPoints,
            isFilled: true,
            color: const Color(0x1A000000),
            borderStrokeWidth: 3.0,
            borderColor: HexColor(AppState.instance.themeModel.primaryColor),
          )
      );
      mapLayers.add(PolygonLayer(
        polygons: polygons,
      ));
    });
  }
}
