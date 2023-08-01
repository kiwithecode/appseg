import 'package:flutter/material.dart';
import 'package:sammseguridad_apk/widgets/Appbar.dart';
import 'package:sammseguridad_apk/widgets/Drawer.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PerfilPage extends StatelessWidget {
  const PerfilPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Generate QR code data
    final qrData = 'Nombres: María Elena, '
      'Apellidos: Campuzano Loor, '
      'Cédula: 1710078239, '
      'Número de celular: 0987693034, '
      'Correo electrónico: maelenacampuzano@gmail.com, '
      'Contraseña: xxxxxxxxxx'; // Replace with your QR data

    return Scaffold(
      appBar: CustomAppBar(),
      drawer: CustomDrawer(),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/FOTO-1.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(10.0),
            margin: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: ListView(
              shrinkWrap: true,
              children: [
                SizedBox(height: 20),
                // QR code widget
                Center(
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Cuenta',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30.0, color: Colors.white),
                ),
                SizedBox(height: 10),
                Text(
                  'Información',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25.0, color: Colors.white),
                ),
                SizedBox(height: 40),
                createInfoRow('Nombres:', 'María Elena'),
                createInfoRow('Apellidos:', 'Campuzano Loor'),
                createInfoRow('Cédula:', '1710078239'),
                createInfoRow('Número de celular:', '0987693034'),
                createInfoRow('Correo electrónico:', 'maelenacampuzano@gmail.com'),
                createInfoRow('Contraseña:', 'xxxxxxxxxx'),
                InkWell(
                  onTap: () {
                    // Implementar lógica de cambio de contraseña
                  },
                  child: Text(
                    "Cambiar contraseña",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget createInfoRow(String title, String info) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.0),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          Text(
            info,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}