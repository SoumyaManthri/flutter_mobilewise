import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mobilewise/screens/printer/model/printer_config.dart';
import 'package:flutter_mobilewise/screens/printer/printer_utils.dart';
import 'package:flutter_mobilewise/utils/mobilog.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../utils/common_constants.dart' as constants;
import '../../utils/app_state.dart';
import '../../utils/hex_color.dart';
import '../forms/view_model/form_view_model.dart';

class PrinterView extends StatefulWidget {
  const PrinterView({Key? key}) : super(key: key);

  @override
  State<PrinterView> createState() => _PrinterViewState();
}

class _PrinterViewState extends State<PrinterView> {
  final _formKey = GlobalKey<FormState>();

  late FormViewModel formViewModel;
  late TextEditingController _nameController;
  late TextEditingController _ipController;
  late SharedPreferences _prefs;

  List<PrinterConfig> _printerList = [];
  String? _selectedIpAddress;

  bool isEdit = false;
  int editPos = 0;

  @override
  initState() {
    super.initState();
    initPrinters();
    formViewModel = Provider.of<FormViewModel>(context, listen: false);
    _nameController = TextEditingController();
    _ipController = TextEditingController();
  }

  initPrinters() async {
    _prefs = await SharedPreferences.getInstance();
    String? jsonData = _prefs.getString('printerList');
    if (jsonData != null) {
      // Parse JSON string to list of maps
      List<dynamic> dataMapList = json.decode(jsonData);
      _printerList =
          dataMapList.map((map) => PrinterConfig.fromMap(map)).toList();
    }
    _selectedIpAddress = _prefs.getString('selectedIpAddress');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FormViewModel>(builder: (_, model, child) {
      if (model.isLoading) {
        return child ?? const SizedBox();
      }

      return Scaffold(
          appBar:
              formViewModel.getAppBar(context, title: 'Printer', iconList: [2]),
          body: Container(
              color: HexColor(AppState.instance.themeModel.backgroundColor),
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: _body()));
    });
  }

  _body() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _editTextField('Printer Name', _nameController),
          _editTextField('IP Address', _ipController),
          _getButton(),
          Expanded(
            child: ListView.builder(
              itemCount: _printerList.length,
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        title: Text(_printerList[index].name),
                        subtitle: Text(_printerList[index].ipAddress),
                        value: _printerList[index].ipAddress == _selectedIpAddress,
                        onChanged: (val) async {
                          if (val!) {
                            _selectedIpAddress = _printerList[index].ipAddress;
                            await _prefs.setString(
                                'selectedIpAddress', _selectedIpAddress!);
                            Printer.tcpIP = _selectedIpAddress!;
                          }
                          setState(
                            () {},
                          );
                        },
                      ),
                    ),
                    TextButton(onPressed: () {
                      isEdit = true;
                      editPos = index;
                      _nameController.text = _printerList[index].name;
                      _ipController.text = _printerList[index].ipAddress;
                      setState(() {
                      });
                    }, child: const Text("Edit")),
                    TextButton(onPressed: () async {
                      _printerList.removeAt(index);
                      await savePrinterList();
                      setState(() {
                      });
                    }, child: const Text("Delete")),
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _editTextField(String label, TextEditingController controller) {
    return Center(
        child: Padding(
      padding: const EdgeInsets.only(
        top: constants.mediumPadding,
      ),
      child: TextFormField(
        validator: (value) {
          return validation(value, label);
        },
        autofocus: true,
        controller: controller,
        decoration: borderOutlined(label),
      ),
    ));
  }

  String? validation(String? value, String label) {
    String? errorMsg;
    if (value!.isEmpty) {
      errorMsg = "$label can not be empty";
      return errorMsg;
    }

    if (label == 'IP Address' && !isValidIPAddress(value)) {
      errorMsg = "Kindly enter valid IP Address";
    }
    return errorMsg;
  }

  bool isValidIPAddress(String ipAddress) {
    // Regular expression for IPv4 address validation
    final ipv4Regex = RegExp(
        r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$');

    // Regular expression for IPv6 address validation
    final ipv6Regex = RegExp(
        r'^(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$');

    // Check if the IP address matches either IPv4 or IPv6 regex
    return ipv4Regex.hasMatch(ipAddress) || ipv6Regex.hasMatch(ipAddress);
  }

  InputDecoration borderOutlined(String label) {
    return InputDecoration(
      label: Text(label),
      fillColor: HexColor(AppState.instance.themeModel.backgroundColor),
      filled: true,
      border: OutlineInputBorder(
        borderSide: BorderSide(
            width: 2,
            color: HexColor(AppState.instance.themeModel.primaryColor)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
            width: 2,
            color: HexColor(AppState.instance.themeModel.primaryColor)),
      ),
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: HexColor(AppState.instance.themeModel.textColor))),
      errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(width: 2, color: Colors.red)),
      floatingLabelStyle:
          TextStyle(color: HexColor(AppState.instance.themeModel.primaryColor)),
      labelStyle: const TextStyle(color: Color(constants.hintTextColor)),
      errorStyle: const TextStyle(color: Colors.red),
    );
  }

  _getButton() {
    return Padding(
      padding: const EdgeInsets.only(
          top: constants.mediumPadding, bottom: constants.mediumPadding),
      child: SizedBox(
        height: constants.buttonHeight,
        width: MediaQuery.of(context).size.width,
        child: isEdit ? filledButton(label: 'Update Printer') : filledButton(label: 'Add Printer'),
      ),
    );
  }

  filledButton({Color? bgColor, required String label}) {
    return FilledButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          if (isEdit) {
            _printerList[editPos] = PrinterConfig(
                name: _nameController.text, ipAddress: _ipController.text);
            isEdit = false;
          } else {
            _printerList.add(PrinterConfig(
                name: _nameController.text, ipAddress: _ipController.text));
          }
          // Convert list of PrinterConfig objects to list of maps
          await savePrinterList();
          _nameController.clear();
          _ipController.clear();
          MobiLog.i(
              tag: 'PRINTER_CLASS',
              message: '${_nameController.text}--${_ipController.text}');
          setState(() {});
        }
      },
      style: constants.buttonFilledStyle(
          backgroundColor:
              bgColor ?? HexColor(AppState.instance.themeModel.primaryColor)),
      child: Text(
        label,
        style: buttonTextStyle(),
      ),
    );
  }

  Future<void> savePrinterList() async {
    List<Map<String, dynamic>> dataMapList =
        _printerList.map((data) => data.toMap()).toList();
    // Convert list of maps to JSON string
    String jsonData = json.encode(dataMapList);
    
    await _prefs.setString('printerList', jsonData);
    if (_printerList.length == 1) {
      _selectedIpAddress = _printerList[0].ipAddress;
      Printer.tcpIP = _selectedIpAddress!;
      await _prefs.setString(
          'selectedIpAddress', _selectedIpAddress!);
    }
  }

  buttonTextStyle() {
    return constants.applyStyleV2(
        color: AppState.instance.themeModel.secondaryColor);
  }
}
