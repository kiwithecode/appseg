import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sammseguridad_apk/screens/crear/ScreenCreascuenta.dart';
import 'package:sammseguridad_apk/screens/logins/ScreenFaceID_Huella.dart';
import 'package:sammseguridad_apk/screens/logins/ScreenLogin.dart';

import 'logins/ScreenLoginPin.dart';

class ScreenWelcome extends StatelessWidget {
  const ScreenWelcome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Image.asset('assets/images/SAMMA.png'),
            Text(
              '¡Hola, que gusto verte!',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0040AE)),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Flexible(
                  child: CustomButton(
                    iconData: Icons.mail,
                    text: 'Correo y Contraseña',
                    onPressed: () {
                      Navigator.pushNamed(context, LoginPage.routeName);
                    },
                  ),
                ),
                SizedBox(width: 16),
                Flexible(
                  child: CustomButton(
                    iconData: Icons.fingerprint,
                    text: 'Face ID/Huella',
                    onPressed: () {
                      Navigator.pushNamed(
                          context, ScreenFaceID_Huella.routeName);
                    },
                  ),
                ),
                SizedBox(width: 16),
                Flexible(
                  child: CustomButton(
                    iconData: Icons.lock,
                    text: 'Pin de Seguridad',
                    onPressed: () {
                      Navigator.pushNamed(context, ScreenLoginPin.routeName);
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            RichText(
              text: TextSpan(
                text: '¿No tienes una cuenta? ',
                style: TextStyle(color: Color(0xFF0040AE), fontSize: 16),
                children: <TextSpan>[
                  TextSpan(
                    text: 'Regístrate',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0040AE),
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ScreenCreascuenta(),
                          ),
                        );
                      },
                  ),
                ],
              ),
            ),
            SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
class CustomButton extends StatelessWidget {
  final IconData iconData;
  final String text;
  final VoidCallback onPressed;

  const CustomButton({
    required this.iconData,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        primary: Color(0xFF0040AE),
        backgroundColor: Colors.white,
        side: BorderSide(color: Color(0xFF0040AE), width: 2),
        shadowColor: Colors.grey,
        elevation: 5,
      ),
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(iconData, size: 35),
            Align(
              alignment: Alignment.center,
              child: Text(text),
            ),
          ],
        ),
      ),
    );
  }
}
