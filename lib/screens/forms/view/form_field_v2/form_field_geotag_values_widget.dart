import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../shared/model/framework_form.dart';
import '../../../../utils/app_state.dart';
import '../../../../utils/hex_color.dart';
import '../../view_model/form_view_model.dart';
import '../../../../utils/common_constants.dart' as constants;

class FormFieldGeotagValuesWidget extends StatefulWidget {
  const FormFieldGeotagValuesWidget({
    Key? key,
    required this.field,
    required this.viewModel,
    this.value,
  }) : super(key: key);

  final FrameworkFormField field;
  final FormViewModel viewModel;
  final String? value;

  @override
  State<FormFieldGeotagValuesWidget> createState() => _FormFieldGeotagValuesWidgetState();
}

class _FormFieldGeotagValuesWidgetState extends State<FormFieldGeotagValuesWidget> {

  List<String> latLng = [];

  @override
  void initState() {
    super.initState();
    String value = widget.value ??
        widget.viewModel.dataListSelected?.dataMap?[widget.field.defaultValue]
            ?.value ??
        '';
    if (value.isNotEmpty) {
      latLng = value.split(",");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: _view(),
    );
  }

  _view() {
    return latLng.isEmpty
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
                      initialCenter: LatLng(double.parse(latLng[0]),
                          double.parse(latLng[1])),
                      initialZoom: 13,
                      maxZoom: 19,
                      interactiveFlags: InteractiveFlag.none,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: ['a', 'b', 'c'],
                      ),
                      MarkerLayer(markers: [
                        Marker(
                            point: LatLng(double.parse(latLng[0]),
                                double.parse(latLng[1])),
                            child: const Icon(
                              Icons.location_on_rounded,
                              color: Colors.red,
                              size: constants.markerIconDimension,
                            ))
                      ])
                    ],
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
          initialCenter: LatLng(double.parse(latLng[0]),
              double.parse(latLng[1])),
          initialZoom: 13,
          maxZoom: 19,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate:
            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(markers: [
            Marker(
                point: LatLng(double.parse(latLng[0]),
                    double.parse(latLng[1])),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Colors.red,
                  size: constants.markerIconDimension,
                ))
          ])
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
}
