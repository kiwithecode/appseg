import 'package:flutter/material.dart';
import 'package:sammseguridad_apk/services/ApiService.dart';
import 'package:local_auth/local_auth.dart';

class ScreenFaceID_Huella extends StatefulWidget {
  static const routeName = 'facehuella';
  const ScreenFaceID_Huella({Key? key}) : super(key: key);

  @override
  _ScreenFaceID_HuellaState createState() => _ScreenFaceID_HuellaState();
}

class _ScreenFaceID_HuellaState extends State<ScreenFaceID_Huella> {
  final LocalAuthentication auth = LocalAuthentication();
  final ApiService _apiService = ApiService();

  Future<void> authWithFaceID() async {
    bool hasFaceId = await auth.canCheckBiometrics;
    if (hasFaceId) {
      List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics();
      if (availableBiometrics.contains(BiometricType.face)) {
        final bool didAuthenticate = await auth.authenticate(
          localizedReason: 'Por favor autentíquese para ingresar a la aplicación',
          options: const AuthenticationOptions(biometricOnly: true),
        );

        if (didAuthenticate) {
          // Autenticación exitosa, aquí puedes hacer una llamada a la API
          await _apiService.postData('/login/biometric', {'userId': 'exampleUserId'}, '');
        } else {
          // Maneja el caso cuando la autenticación falla
        }
      }
    }
  }


Future<void> authWithFingerprint() async {
  bool hasFingerprint = await auth.canCheckBiometrics;
  if (hasFingerprint) {
    List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics();
    if (availableBiometrics.contains(BiometricType.fingerprint)) {
      bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Por favor autentíquese para ingresar a la aplicación',
        options: const AuthenticationOptions(biometricOnly: true),
      );

      if (didAuthenticate) {
        // Autenticación exitosa, aquí puedes hacer una llamada a la API
        await _apiService.postData('/login/biometric', {'userId': 'exampleUserId'}, '');
      } else {
        // Maneja el caso cuando la autenticación falla
      }
    }
  }
}





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: PageView(
          children: [
            _buildFaceIdScreen(),
            _buildFingerprintScreen(),
          ],
        ),
      ),
    );
  }

  Widget _buildFaceIdScreen() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text('Ingreso por Face ID',
              style: TextStyle(color: Color(0xFF001554), fontSize: 35)),
          SizedBox(height: 80),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 30.0),
            child: Text(
              'El ingreso a la app se encuentra protegido mediante la biometría de tu dispositivo celular.',
              style: TextStyle(color: Color(0xFF001554)),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 80),
          ElevatedButton(
            onPressed: authWithFaceID,
            child: const Text(
              'Usar Face ID',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 80),
              primary: Color(0xFF297DE2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFingerprintScreen() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Ingreso con Huella',
              style: TextStyle(color: Color(0xFF001554), fontSize: 35)),
          SizedBox(height: 80),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 30.0),
            child: Text(
              'El ingreso a la app se encuentra protegido mediante la lectura de la huella de tu dispositivo celular.',
              style: TextStyle(color: Color(0xFF001554)),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 80),
          ElevatedButton(
            onPressed: authWithFingerprint,
            child: const Text(
              'Usar Huella Digital',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 80),
              primary: Color(0xFF297DE2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
