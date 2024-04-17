library widget_zpl_converter;

import 'package:zsdk/zsdk.dart';

import '../../utils/mobilog.dart';

class Printer {
  Printer(this.zpl);

  static const String tag = 'Printer';
  final String zpl;
  static String tcpIP = '192.168.18.49';

  print(int noOfCopies) async {
    final zsdk = ZSDK();
    MobiLog.v(tag: tag, message: tcpIP);
    for (int i = 0; i < noOfCopies; i++) {
      var value = await zsdk.printZplDataOverTCPIP(
        data: zpl,
        address: tcpIP,
      );

      MobiLog.i(tag: tag, message: 'Printing DONE $value');
    }
  }

  Function onPrinterFound = (name, ipAddress) {
    MobiLog.i(tag: tag, message: 'PrinterFound : $name  $ipAddress');
  };

  Function onPrinterDiscoveryDone = () {
    MobiLog.i(tag: tag, message: 'Discovery Done');
  };

  Function onChangePrinterStatus = (status, color) {
    MobiLog.i(tag: tag, message: 'Change printer status: $status $color');
  };

  Function onPermissionDenied = () {
    MobiLog.i(tag: tag, message: 'Permission Deny');
  };
}
