import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:sammseguridad_apk/widgets/Appbar.dart';
import 'package:sammseguridad_apk/widgets/Drawer.dart';

class QRViewExample extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // Variable to store the scan result
  String qrText = "No data scanned yet";

  @override
  Widget build(BuildContext context) {  
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: CustomDrawer(),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Text(qrText), // Display the scanned text
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData != null && scanData.code != null) {
        setState(() {
          qrText = 'QR Code Scanned: ' + scanData.code!;
        });
      } else {
        setState(() {
          qrText = 'No data';
        });
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
