import 'package:flutter/material.dart';
import 'package:flutter_mobilewise/utils/app_state.dart';
import 'package:flutter_mobilewise/utils/hex_color.dart';

import 'loading_indicator.dart';

class DialogBuilder {
  DialogBuilder(this.context);

  final BuildContext context;

  void showLoadingIndicator([String? text]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              /*shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0))
              ),*/
              backgroundColor:
                  HexColor(AppState.instance.themeModel.primaryColor),
              content: Container(
                height: 100,
                child: Column(
                  children: [
                    CircularProgressIndicator(
                        color: HexColor(
                      AppState.instance.themeModel.secondaryColor,
                    )),
                    Container(
                        margin: EdgeInsets.only(top: 20),
                        child: Text(
                          text!,
                          style: TextStyle(
                              color: HexColor(
                                  AppState.instance.themeModel.secondaryColor)),
                        )),
                  ],
                ),
              ),
            ));
      },
    );
  }

  void hideOpenDialog() {
    Navigator.of(context).pop();
  }
}
