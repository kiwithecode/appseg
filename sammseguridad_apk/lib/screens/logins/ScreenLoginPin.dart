import 'dart:async';
import 'package:flutter/material.dart';

import '../../services/ApiService.dart';
import '../ScreanMenu.dart';

class ScreenLoginPin extends StatefulWidget {
  static const routeName = 'loginPin';

  const ScreenLoginPin({Key? key}) : super(key: key);

  @override
  _ScreenLoginPinState createState() => _ScreenLoginPinState();
}

class _ScreenLoginPinState extends State<ScreenLoginPin> {
  static const _fontSize = 20.0;
  static const _buttonFontSize = 18.0;

  final ApiService _apiService = ApiService();
  final List<int> _pin = [];

  Widget _buildNumberButton(int number) {
    return ElevatedButton(
      onPressed: () => onNumberSelected(number),
      child: Text(
        number.toString(),
        style: TextStyle(fontSize: _fontSize, color: Color(0xFF0040AE)),
      ),
      style: ElevatedButton.styleFrom(
        primary: Color(0xFF8E8E8E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0.0),
        ),
      ),
    );
  }

  Widget _buildPinIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        if (index < _pin.length) {
          return Icon(Icons.circle,  size: 40.0,  color: Color(0xFF0040AE));
        }
        return Icon(Icons.circle_outlined ,size: 40.0);
      }),
    );
  }

  void onNumberSelected(int number) {
    setState(() {
      if (_pin.length < 4) {
        _pin.add(number);
      }
      if (_pin.length == 4) {
        login(_pin.join());
      }
    });
  }

  Future<void> login(String pin) async {
    try {
      await _apiService.postData('/login/loginPin', {'Pin': pin}, '');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ScreanMenu()),
      );
    } catch (e) {
      showCustomSnackBar(context, 'Error al iniciar sesión: $e', Colors.red);
      _pin.clear();
    }
  }

  void showCustomSnackBar(BuildContext context, String message, Color color) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildPinIndicator(),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              childAspectRatio: 1.2,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
              padding: const EdgeInsets.all(30.0),
              children: [
                ...List.generate(9, (index) => _buildNumberButton(index + 1)),
                IconButton(
                  onPressed: _pin.isNotEmpty
                      ? () => setState(() {
                            _pin.removeLast();
                          })
                      : null,
                  icon: const Icon(Icons.backspace_outlined),
                  color: Color(0xFF0040AE),
                ),
                _buildNumberButton(0),
                Container(),
              ],
            ),
            Container(
              width: 250, // ajusta este valor según tus necesidades
              child: ElevatedButton(
                onPressed: _pin.length == 4
                    ? () async {
                        try {
                          await login(_pin.join());
                          showCustomSnackBar(context,
                              'Inicio de sesión exitoso!', Colors.green);
                        } catch (e) {
                          showCustomSnackBar(context,
                              'Error al iniciar sesión: $e', Colors.red);
                        }
                      }
                    : null,
                child: const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: _buttonFontSize,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 80),
                  primary: Color(0xFF0040AE),
                  onSurface: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              width:
                  250, // este valor debe ser el mismo que el del botón de 'Login'
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Regresar',
                  style: TextStyle(
                    fontSize: _buttonFontSize,
                    color: Color(0xFF0040AE),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 80),
                  primary: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Color(0xFF0040AE), width: 2),
                    borderRadius: BorderRadius.circular(0.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
}
