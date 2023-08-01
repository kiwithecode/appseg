import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_share/flutter_share.dart';

import 'package:flutter/services.dart';
import 'package:sammseguridad_apk/provider/mainprovider.dart';
import 'package:sammseguridad_apk/widgets/Appbar.dart';
import 'package:sammseguridad_apk/widgets/Drawer.dart';

import '../services/ApiService.dart';

import 'package:provider/provider.dart';

class ScreenGenerarVisita extends StatefulWidget {
  const ScreenGenerarVisita({Key? key}) : super(key: key);
  @override
  _ScreenGenerarVisitaState createState() => _ScreenGenerarVisitaState();
}

String token = "";

class _ScreenGenerarVisitaState extends State<ScreenGenerarVisita> {
  late DateTime _selectedDate = DateTime.now();
  late TimeOfDay _selectedTime = TimeOfDay.now();
  int _selectedDuration = 1;
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _plateController = TextEditingController();

  String _qrData = "";

  void _shareQRData(String qrData, String imagePath) async {
    await FlutterShare.shareFile(
      title: 'Compartir QR',
      text: 'Aquí está tu código QR y sus datos:\n$qrData',
      filePath: imagePath, // Pass string directly here.
      chooserTitle: 'Compartir con...',
    );
  }

  void _copyQRDataToClipboard(String qrData) {
    Clipboard.setData(ClipboardData(text: qrData));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('QR data copied to clipboard')),
    );
  }

  GlobalKey _qrKey = GlobalKey();

  Future<String> _downloadQRCode(GlobalKey qrKey) async {
    RenderRepaintBoundary boundary =
        qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    var image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    // Guarda la imagen en el directorio temporal del dispositivo
    final directory = await getTemporaryDirectory();
    final imagePath = '${directory.path}/qr_code.png';
    File imageFile = File(imagePath);
    await imageFile.writeAsBytes(pngBytes);

    return imageFile.path; // Retorna la ruta de la imagen
  }

  void _sendQRCodeByEmail(String qrData) {
    // TODO: Implement send by email functionality
    // You can use a package like 'url_launcher' to open the email client with pre-filled data
  }

  @override
  void initState() {
    super.initState();
    final mainProviderSave = Provider.of<MainProvider>(context, listen: false);

    mainProviderSave.getPreferencesToken().then((dataToken) {
      setState(() {
        token = dataToken.toString();
        mainProviderSave.updateToken(token);
      });
    });
  }

  Future<void> _generateQRCode(
      MainProvider mainProvider, ApiService apiService) async {
    if (_formKey.currentState!.validate()) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
      String formattedTime = DateFormat.Hm().format(DateTime.now());
      String qrData =
          '${DateFormat('dd/MM/yyyy').format(_selectedDate)},${_selectedTime.format(context)},${_selectedDuration},${_idController.text},${_nameController.text},${_lastNameController.text},${_plateController.text}';

      Map<String, dynamic> data = {
        'date': formattedDate.toString(),
        'time': formattedTime.toString(),
        'duration': _selectedDuration,
        'cedula': _idController.text,
        'name': _nameController.text,
        'lastName': _lastNameController.text,
        'placa': _plateController.text,
      };

      try {
        print('Data: $data');
        var response =
            await apiService.postData('/visitas/registraVisita', data, token);
        print('Data: $data');

        print(response);
      } catch (e) {
        print('Failed to post data: $e');
      }

      setState(() {
        _qrData = qrData;
      });

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    child: BarcodeWidget(
                      key: _qrKey,
                      barcode: Barcode.qrCode(),
                      data: qrData,
                      width: 200,
                      height: 200,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text('Datos de la invitación:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(Icons.credit_card),
                              title: Text('Cédula'),
                              subtitle: Text(_idController.text),
                            ),
                            ListTile(
                              leading: Icon(Icons.person),
                              title: Text('Nombres'),
                              subtitle: Text(_nameController.text),
                            ),
                            ListTile(
                              leading: Icon(Icons.calendar_today),
                              title: Text('Fecha'),
                              subtitle: Text(DateFormat('yyyy-MM-dd')
                                  .format(_selectedDate)),
                            ),
                            ListTile(
                              leading: Icon(Icons.directions_car),
                              title: Text('Placa'),
                              subtitle: Text(_plateController.text),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(Icons.person),
                              title: Text('Apellidos'),
                              subtitle: Text(_lastNameController.text),
                            ),
                            ListTile(
                              leading: Icon(Icons.access_time),
                              title: Text('Hora'),
                              subtitle:
                                  Text(DateFormat.Hm().format(DateTime.now())),
                            ),
                            ListTile(
                              leading: Icon(Icons.timer),
                              title: Text('Duración'),
                              subtitle: Text('$_selectedDuration horas'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.share),
                onPressed: () async {
                  var imagePath = await _downloadQRCode(_qrKey);
                  _shareQRData(qrData, imagePath);
                },
              ),
              IconButton(
                icon: Icon(Icons.copy),
                onPressed: () => _copyQRDataToClipboard(qrData),
              ),
              IconButton(
                icon: Icon(Icons.download),
                onPressed: () async {
                  var status = await Permission.photos.status;
                  if (!status.isGranted) {
                    status = await Permission.photos.request();
                  }
                  if (status.isGranted) {
                    _downloadQRCode(_qrKey);
                  } else {
                    print("Permission denied.");
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.email),
                onPressed: () => _sendQRCodeByEmail(qrData),
              ),
            ],
          );
        },
      );
    }
  }

  Widget _buildDatePickerButton() {
    return TextButton(
      onPressed: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (picked != null && picked != _selectedDate) {
          setState(() {
            _selectedDate = picked;
          });
        }
      },
      child: Text('Seleccionar Fecha'),
    );
  }

  Widget _buildTimePickerButton() {
    return TextButton(
      onPressed: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (picked != null && picked != _selectedTime) {
          setState(() {
            _selectedTime = picked;
          });
        }
      },
      child: Text(
          'Seleccionar Hora ${DateFormat.Hm().format(DateTime(0, _selectedTime.hour, _selectedTime.minute))}'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mainProvider = Provider.of<MainProvider>(context, listen: false);
    final apiService = Provider.of<ApiService>(context, listen: false);

    return Scaffold(
      appBar: CustomAppBar(),
      drawer: CustomDrawer(),
      //bottomNavigationBar: MyBottomNavigationBar(),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDatePickerButton(),
            _buildTimePickerButton(),
            DropdownButton<int>(
              value: _selectedDuration,
              items: [1, 2, 3, 4, 5, 6].map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value horas'),
                );
              }).toList(),
              onChanged: (int? val) =>
                  setState(() => _selectedDuration = val ?? _selectedDuration),
            ),
            SizedBox(height: 20),
            Text('Información del Invitado'),
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _idController,
                    decoration: InputDecoration(
                      labelText: 'Cédula',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xff0040AE)),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa la cédula';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nombres',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xff0040AE)),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa los nombres';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      labelText: 'Apellidos',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xff0040AE)),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa los apellidos';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _plateController,
                    decoration: InputDecoration(
                      labelText: 'Placa',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xff0040AE)),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa la placa';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _generateQRCode(mainProvider, apiService),
              icon: Icon(Icons.filter_center_focus),
              label: Text('Generar QR'),
              style: ElevatedButton.styleFrom(
                primary: Color(0xff0040AE),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
