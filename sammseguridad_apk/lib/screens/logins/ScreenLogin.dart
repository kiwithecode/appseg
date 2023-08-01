import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sammseguridad_apk/provider/mainprovider.dart';
import 'package:sammseguridad_apk/screens/ScreanMenu.dart';
import 'package:sammseguridad_apk/services/ApiService.dart';

class LoginPage extends StatefulWidget {
  static const routeName = 'login';

  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  static const _fontSize = 20.0;
  static const _paddingSize = 15.0;
  static const _buttonFontSize = 18.0;
  static const _sizedBoxHeight = 10.0;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();

  late MainProvider _mainProvider;

  // Añade esta línea
  bool _obscureText = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mainProvider = Provider.of<MainProvider>(context);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isObscured = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF0040AE), fontSize: _fontSize),
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: _sizedBoxHeight),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: label,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(color: Color(0xFF0040AE)),
            ),
            // Añade un sufijo de icono aquí
            suffixIcon: isObscured
                ? IconButton(
                    icon: Icon(
                      // Cambiar el ícono en función de si la contraseña está oculta o no
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      // Cambia el estado de _obscureText cuando se presiona el botón
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
          ),
          obscureText: isObscured ? _obscureText : false, // Modifica esta línea
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, coloque su $label';
            }
            return null;
          },
        ),
        const SizedBox(height: _sizedBoxHeight),
      ],
    );
  }

  saveJwtToken(String token) {
    setState(() {
      _mainProvider.updateToken(token);
    });
  }

  Future<void> postData(
      String endpoint, Map<String, dynamic> data, String jwtToken) async {
    try {
      var response = await _apiService.postData(endpoint, data, jwtToken);
      if (response['access_token'] != null) {
        _mainProvider.updateToken(response['access_token']);
      }
    } catch (e) {
      print(e);
      throw Exception('Failed to post data: $e');
    }
  }

  Future<void> login(String Codigo, String Clave) async {
    try {
      await postData('/login/login', {'Codigo': Codigo, 'Clave': Clave}, '');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ScreanMenu()),
      );
    } catch (e) {
      showCustomSnackBar(context, 'Error al iniciar sesión: $e', Colors.red);
      _usernameController.clear();
      _passwordController.clear();
    }
  }

  void showCustomSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(_paddingSize),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 3 * _sizedBoxHeight),
                  _buildTextField('Usuario', _usernameController),
                  _buildTextField('Contraseña', _passwordController,
                      isObscured: true),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Olvidé mi contraseña',
                          style: TextStyle(
                            color: Color(0xFF0040AE),
                            fontSize: _fontSize,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: _sizedBoxHeight),
                  Container(
                    width: 250,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            await login(_usernameController.text,
                                _passwordController.text);
                            showCustomSnackBar(context,
                                'Inicio de sesión exitoso!', Colors.green);
                          } catch (e) {
                            showCustomSnackBar(context,
                                'Error al iniciar sesión: $e', Colors.red);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        primary: Color(0xFF0040AE),
                        onSurface: Colors.grey,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Color(0xFF0040AE), width: 2),
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: _buttonFontSize,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: _sizedBoxHeight),
                  Container(
                    width: 250,
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
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 80),
                        primary: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Color(0xFF0040AE), width: 2),
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: _sizedBoxHeight),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}