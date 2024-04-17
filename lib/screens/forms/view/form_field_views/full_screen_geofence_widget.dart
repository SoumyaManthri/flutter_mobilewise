import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../../shared/model/framework_form.dart';
import '../../../../shared/model/geofence_arguments.dart';
import '../../../../utils/app_state.dart';
import '../../../../utils/hex_color.dart';
import '../../../../utils/map_util.dart';
import '../../../../utils/util.dart';
import '../../../../utils/common_constants.dart' as constants;
import '../../model/geofence_points_model.dart';
class FullScreenGeofenceWidget extends StatefulWidget {
  const FullScreenGeofenceWidget({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.selectedPoints,
    required this.field,
  }) : super(key: key);

  final double latitude;
  final double longitude;
  final List<LatLng> selectedPoints;
  final FrameworkFormField field;

  @override
  State<FullScreenGeofenceWidget> createState() => _FullScreenGeofenceWidgetState();
}

class _FullScreenGeofenceWidgetState extends State<FullScreenGeofenceWidget> {
  MapController mapController = MapController();
  late double lat;
  late double lng;
  List<Marker> mapMarkers = [];
  LatLng mapCenter = const LatLng(0,0);
  String geofencingMode = "";
  String geometryType = "";
  bool isTracking = false;
  List<LatLng> selectedPoints = [];
  List<Marker> selectedPointMarkers = [];
  List<Polyline> polylines = [];
  List<Polygon> polygons = [];
  List<Widget> mapLayers = [];
  CurrentLocationLayer? currentUserLocationLayer;

  @override
  void initState() {
    super.initState();
    initializeSelectedPoints();
    initializeGeometryType();
    initializeGeofencingMode();
    initializeMapLayers();
    initializeMapCenter();
  }

  initializeSelectedPoints() {
    selectedPoints = widget.selectedPoints;
  }

  initializeMapCenter() {
    if (selectedPoints.isNotEmpty) {
      mapCenter = MapUtil.calculateCentroid(selectedPoints);
      drawAsset();
    } else {
      mapCenter = LatLng(widget.latitude, widget.longitude);
    }
  }

  initializeMapLayers() {
    mapLayers.add(TileLayer(
      urlTemplate:
      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
      subdomains: ['a', 'b', 'c'],
    ));
    currentUserLocationLayer = CurrentLocationLayer(
      positionStream: const LocationMarkerDataStreamFactory()
          .fromGeolocatorPositionStream(),
      alignPositionOnUpdate: AlignOnUpdate.never,
      alignDirectionOnUpdate: AlignOnUpdate.never,
      style: LocationMarkerStyle(
          marker: const DefaultLocationMarker(),
          markerSize: const Size.square(20),
          markerDirection: MarkerDirection.heading,
          accuracyCircleColor: Colors.blue.withOpacity(0.2),
          headingSectorRadius: 80,
          showAccuracyCircle: true,
          showHeadingSector: true),
    );
    mapLayers.add(
      currentUserLocationLayer!
    );
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

  startTrackingUserWalkPath() {
    AppState.instance.startTrackingUserLocation();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      Position userLocation = AppState.instance.currentUserLocation!;
      double distanceInMeters = -1;
      if (selectedPoints.isNotEmpty) {
        distanceInMeters = MapUtil.calculateDistance(userLocation.latitude,userLocation.longitude,selectedPoints.last.latitude,selectedPoints.last.longitude) * 1000;
      }
      if (distanceInMeters == -1 || distanceInMeters > 5) {
        setState(() {
          selectedPoints.add(LatLng(userLocation.latitude!, userLocation.longitude!));
        });
        drawAsset();
      }
      if (!isTracking) {
        timer.cancel();
        AppState.instance.stopTrackingUserLocation();
      }
    });
  }

  Marker getUserLocationMarker(double lat, double lng, double heading) {
    return Marker(
      point: LatLng(lat, lng),
      child: Transform.rotate(
        angle: (-heading % (2 * pi)),
        child: Image.asset("assets/images/user_location_marker.png")
      ),
    );
  }

  clearData() {
    setState(() {
      isTracking = false;
      selectedPoints.clear();
      selectedPointMarkers.clear();
      polylines.clear();
      polygons.clear();
      mapLayers.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: mapCenter,
                initialZoom: 13,
                maxZoom: 19,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                ),
                onTap: (tapPosition, latLng) {
                  /// When tapped on existing point it must be removed
                  removeSelectedPointIfExists(latLng);
                },
                onLongPress: (tapPosition, latLng) {
                  /// Drop new point on the map
                  if (geofencingMode == constants.geofenceTypeManual) {
                    bool validTapPosition = updateSelectedPoints(latLng);
                    if(validTapPosition) {
                      drawAsset();
                    }
                  }
                }
              ),
              mapController: mapController,
              children: mapLayers,
            ),
            mapBottomButtons(),
          ],
        )
      )
    );
  }

  Widget mapBottomButtons() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.topLeft,
            child: InkWell(
              onTap: () {
                /// onBackPressed
                clearData();
                Navigator.pop(context, GeofenceArguments(selectedPoints));
              },
              child: const Padding(
                padding: EdgeInsets.fromLTRB(
                  constants.mediumPadding,
                  constants.largePadding * 1.5,
                  0.0,
                  0.0,
                ),
                child: Icon(
                  Icons.close,
                  size: constants.markerIconDimension,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
        bottomButton(),
      ],
    );
  }

  Widget bottomButton() {
    if (geofencingMode == constants.geofenceTypeManual || (selectedPoints.isNotEmpty && !isTracking)) {
      return Row(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                0.0, 0.0, 0.0, constants.mediumPadding),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              height: constants.formButtonBarHeight,
              child: Padding(
                padding: const EdgeInsets.all(constants.mediumPadding),
                child: SizedBox(
                  height: constants.buttonHeight,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedPoints.clear();
                        selectedPointMarkers.clear();
                        polylines.clear();
                        polygons.clear();
                        mapLayers.clear();
                      });
                      initializeMapLayers();
                    },
                    style: constants.buttonFilledStyle(
                        backgroundColor: HexColor(
                            AppState.instance.themeModel.primaryColor)),
                    child: Text(
                      constants.clear,
                      style: constants.buttonTextStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                0.0, 0.0, 0.0, constants.mediumPadding),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              height: constants.formButtonBarHeight,
              child: Padding(
                padding: const EdgeInsets.all(constants.mediumPadding),
                child: SizedBox(
                  height: constants.buttonHeight,
                  child: ElevatedButton(
                    onPressed: () {
                      /// onBackPressed
                      List<GeofencePointsModel> latLngList = [];
                      for (LatLng latLng in selectedPoints) {
                        GeofencePointsModel geofencePoint = GeofencePointsModel(latitude: latLng.latitude, longitude: latLng.longitude);
                        latLngList.add(geofencePoint);
                      }
                      AppState.instance.addToFormTempMap(
                          widget.field.key, json.encode(latLngList));
                      Navigator.pop(context, GeofenceArguments(selectedPoints));
                    },
                    style: constants.buttonFilledStyle(
                        backgroundColor: HexColor(
                            AppState.instance.themeModel.primaryColor)),
                    child: Text(
                      constants.confirm,
                      style: constants.buttonTextStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
    if (isTracking) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
            0.0, 0.0, 0.0, constants.mediumPadding),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: constants.formButtonBarHeight,
          child: Padding(
            padding: const EdgeInsets.all(constants.mediumPadding),
            child: SizedBox(
              height: constants.buttonHeight,
              child: ElevatedButton(
                onPressed: () {
                  updateIsTracking();
                },
                style: constants.buttonFilledStyle(
                    backgroundColor: HexColor(
                        AppState.instance.themeModel.primaryColor)),
                child: Text(
                  constants.stopTracking,
                  style: constants.buttonTextStyle,
                ),
              ),
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          0.0, 0.0, 0.0, constants.mediumPadding),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: constants.formButtonBarHeight,
        child: Padding(
          padding: const EdgeInsets.all(constants.mediumPadding),
          child: SizedBox(
            height: constants.buttonHeight,
            child: ElevatedButton(
              onPressed: () {
                updateIsTracking();
                startTrackingUserWalkPath();
              },
              style: constants.buttonFilledStyle(
                  backgroundColor: HexColor(
                      AppState.instance.themeModel.primaryColor)),
              child: Text(
                constants.startTracking,
                style: constants.buttonTextStyle,
              ),
            ),
          ),
        ),
      ),
    );
  }

  updateIsTracking() {
    setState(() {
      isTracking = !isTracking;
    });
  }

  removeSelectedPointIfExists(LatLng latLng) {
    double safeDistance = 10;
    for(int i=0; i<selectedPoints.length;i++){
      double distanceInMeters = MapUtil.calculateDistance(latLng.latitude,latLng.longitude,selectedPoints[i].latitude,selectedPoints[i].longitude) * 1000;
      if(distanceInMeters < safeDistance){
        setState(() {
          selectedPoints.remove(selectedPoints[i]);
        });
        drawAsset();
      }
    }
  }

  updateSelectedPoints(LatLng latLng) {
    bool isLatLngInBoundary = true;//MapUtil.containsLocation(latLng, AppState.instance.ulbBoundaryCoordinates!, false);
    if(isLatLngInBoundary) {
      selectedPoints.add(latLng);
      return true;
    } else {
      Util.instance.showSnackBar(context, "Please select a point inside current ULB");
      return false;
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
}
