import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../shared/model/framework_form.dart';
import '../../../../utils/app_state.dart';
import '../../../../utils/hex_color.dart';
import '../../../../utils/map_util.dart';
import '../../model/geofence_points_model.dart';
import '../../view_model/form_view_model.dart';
import '../../../../utils/common_constants.dart' as constants;
class FormFieldGeofenceValuesWidget extends StatefulWidget {
  const FormFieldGeofenceValuesWidget({
    Key? key,
    required this.field,
    required this.viewModel,
    this.value,
  }) : super(key: key);

  final FrameworkFormField field;
  final FormViewModel viewModel;
  final String? value;

  @override
  State<FormFieldGeofenceValuesWidget> createState() => _FormFieldGeofenceValuesWidgetState();
}

class _FormFieldGeofenceValuesWidgetState extends State<FormFieldGeofenceValuesWidget> {
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
    String value = widget.value ??
        widget.viewModel.dataListSelected?.dataMap?[widget.field.defaultValue]
            ?.value ??
        '';
    if (value.isNotEmpty) {
      List<GeofencePointsModel> geofencePoints = [];
      dynamic decodedValue = json.decode(value);
      geofencePoints = (decodedValue as List?)!.map((dynamic e) => GeofencePointsModel.fromJson(e as Map<String, dynamic>)).toList();
      for (int i = 0; i < geofencePoints.length; i++) {
        selectedPoints.add(LatLng(geofencePoints[i].latitude,geofencePoints[i].longitude));
      }
    }
    initializeMapLayers();
    initializeGeometryType();
    initializeGeofencingMode();
    if (selectedPoints.isNotEmpty) {
      mapCenter = MapUtil.calculateCentroid(selectedPoints);
      drawAsset();
    }
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: _view(),
    );
  }

  _view() {
    return selectedPoints.isEmpty
        ? const SizedBox()
        : Padding(
      padding: const EdgeInsets.symmetric(vertical:constants.mediumPadding, horizontal:constants.mediumPadding),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.field.label,
              style: constants.smallGreyTextStyle,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  0.0, constants.mediumPadding, 0.0, 0.0),
              child: Container(
                decoration: borderOutlined(),
                width: MediaQuery.of(context).size.width,
                height: constants.cameraPlaceholderImageHeight,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(5.0),
                  ),
                  child: FlutterMap(
                    options: MapOptions(
                      onTap: (tapPosition, latLng) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => _fullScreenView()));
                      },
                      initialCenter: mapCenter,
                      initialZoom: 13,
                      maxZoom: 19,
                      interactiveFlags: InteractiveFlag.none,
                    ),
                    children: mapLayers,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _fullScreenView() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HexColor(AppState.instance.themeModel.primaryColor),
        title: Text(
          widget.field.label,
          style: TextStyle(
            color: HexColor(AppState.instance.themeModel.secondaryColor),
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(
          color: HexColor(AppState.instance.themeModel.secondaryColor),
        ),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: mapCenter,
          initialZoom: 13,
          maxZoom: 19,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
          ),
        ),
        children: mapLayers,
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
}
