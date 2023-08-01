import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ScreenCreascuenta extends StatefulWidget {
  @override
  _ScreenCreascuentaState createState() => _ScreenCreascuentaState();
}

class _ScreenCreascuentaState extends State<ScreenCreascuenta> {
  XFile? _imageFile;
  int _currentStep = 0;
  List<int> _pin = [];

  Future getImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
        _currentStep++;
      });
    }
  }

  void confirmPhoto() {
    if (_imageFile != null) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void createPIN() {
    setState(() {
      _currentStep++;
    });
  }

  void submitForm() {
    // Aquí puedes agregar la lógica para enviar el formulario de creación de cuenta
    // por ejemplo, hacer una llamada a una API para registrar la cuenta
  }
 Widget _buildNumberButton(int number) {
    return Container(
      margin: EdgeInsets.all(5),
      child: ElevatedButton(
        onPressed: () => onNumberSelected(number),
        child: Text(
          number.toString(),
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          primary: Color(0xFF297DE2),
          padding: EdgeInsets.all(25), // Aumenta el padding para hacer el botón más grande
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }

  void onNumberSelected(int number) {
    setState(() {
      if (_pin.length < 4) {
        _pin.add(number);
      }
      if (_pin.length == 4) {
        createPIN();
      }
    });
  }

Widget _buildPINIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        if (index < _pin.length) {
          return CircleAvatar(
            radius: 18, // Aumenta el tamaño del círculo
            backgroundColor: Color(0xFF297DE2),
          );
        }
        return CircleAvatar(
          radius: 18, // Aumenta el tamaño del círculo
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
        );
      }),
    );
  }

@override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Container(
          color: Colors.white,
          child: Stepper(
            type: StepperType.horizontal,
            currentStep: _currentStep,
            controlsBuilder:
                (BuildContext context, ControlsDetails controlsDetails) {
              return SizedBox.shrink();
            },
            steps: [
              Step(
                title:
                    Text(''), // Agrega aquí el título que deseas para tu paso
                isActive: _currentStep == 0,
                content: Column(
                  children: [
                    Text(
                      'Reconocimiento Facial',
                      style: TextStyle(
                        color: Color(0xFF001554),
                        fontWeight:
                            FontWeight.bold, // Esto hace el texto en negrita.
                        fontSize: 35.0,
                        // Esto hace el texto más grande. Ajusta el valor a tus necesidades.
                      ),
                    ),
                    SizedBox(
                      height:
                          40, // Esto añade un espacio entre el texto y la siguiente Row.
                    ),
                    Column(
                      children: [
                        Icon(
                          Icons.account_circle, // Ícono de usuario genérico.
                          color: Color(0xFF001554),
                          size:
                              150.0, // Ajusta el tamaño del ícono a tus necesidades.
                        ),
                        SizedBox(
                          height:
                              80, // Esto añade un espacio entre el ícono y el texto.
                        ),
                        Text(
                          'Escanea tu cara para verificar tu identidad.',
                          style: TextStyle(
                            color: Color(0xFF001554),
                            fontWeight: FontWeight
                                .bold, // Esto hace el texto en negrita.
                            fontSize:
                                20.0, // Esto hace el texto más grande. Ajusta el valor a tus necesidades.
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height:
                          80, // Esto añade un espacio entre la Row y el botón.
                    ),
                    ElevatedButton(
                      onPressed: getImage,
                      child: Text(
                        'Empezar',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xFF297DE2),
                      ),
                    ),
                  ],
                ),
              ),
              Step(
                title: Text(
                  '',
                  style: TextStyle(color: Color(0xFF001554)),
                ),
                isActive: _currentStep == 1,
                content: Column(
                  children: [
                    Text(
                      'Reconocimiento Facial',
                      style: TextStyle(
                        color: Color(0xFF001554),
                        fontWeight:
                            FontWeight.bold, // Esto hace el texto en negrita.
                        fontSize:
                            35.0, // Esto hace el texto más grande. Ajusta el valor a tus necesidades.
                      ),
                    ),
                    SizedBox(
                      height:
                          40, // Esto añade un espacio entre el texto y la siguiente Row.
                    ),
                    Column(
                      children: [
                        if (_imageFile != null)
                          Image.file(
                            File(_imageFile!.path),
                            height:
                                150.0, // Ajusta el tamaño de la imagen a tus necesidades.
                            width:
                                150.0, // Ajusta el ancho de la imagen a tus necesidades.
                          ),
                        SizedBox(
                          height:
                              80, // Esto añade un espacio entre la imagen y el texto.
                        ),
                        Text(
                          'Por favor, pon tu cara dentro del cuadrado y quedate quieto para tomar la foto.',
                          style: TextStyle(
                            color: Color(0xFF001554),
                            fontWeight: FontWeight
                                .bold, // Esto hace el texto en negrita.
                            fontSize:
                                20.0, // Esto hace el texto más grande. Ajusta el valor a tus necesidades.
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height:
                          80, // Esto añade un espacio entre la Row y el botón.
                    ),
                    ElevatedButton(
                      onPressed: confirmPhoto,
                      child: Text(
                        'Confirmar Foto',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xFF297DE2),
                      ),
                    ),
                  ],
                ),
              ),
              Step(
                title: Text(
                  '',
                  style: TextStyle(color: Color(0xFF001554)),
                ),
                isActive: _currentStep == 2,
                content: Column(
                  children: [
                    Text(
                      'Ingrese un PIN para su cuenta:',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 20),
                    _buildPINIndicator(),
                    SizedBox(height: 20),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: List.generate(9, (index) {
                        return _buildNumberButton(index + 1);
                      })
                        ..add(_buildNumberButton(0))
                        ..add(
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                if (_pin.isNotEmpty) {
                                  _pin.removeLast();
                                }
                              });
                            },
                            child: Text(
                              'Borrar',
                              style:
                                  TextStyle(fontSize: 24, color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xFF001554),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 20,
                              ),
                            ),
                          ),
                        )
                        ..add(
                          ElevatedButton(
                            onPressed: _pin.length == 4 ? createPIN : null,
                            child: Text(
                              'OK',
                              style:
                                  TextStyle(fontSize: 24, color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xFF001554),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 20,
                              ),
                            ),
                          ),
                        ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
              Step(
                title: Text(
                  '',
                  style: TextStyle(color: Color(0xFF001554)),
                ),
                isActive: _currentStep == 3,
                content: Column(
                  children: [
                    Text('Ingrese los datos para crear su cuenta:'),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Nombres completos',
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Apellidos completos',
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Cédula de identidad',
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Correo electrónico',
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Número de celular',
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Aquí puedes agregar el código para manejar la creación de la cuenta.
                        // Después de que la cuenta se ha creado exitosamente, muestra el diálogo.

                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Cuenta Registrada'),
                              content: Text(
                                  'Su cuenta ha sido registrada exitosamente.'),
                              actions: [
                                TextButton(
                                  child: Text('OK'),
                                  onPressed: () {
                                    // Cierra el diálogo
                                    Navigator.of(context).pop();
                                    // Después de cerrar el diálogo, regresa a ScreenWelcome.
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Text('Crear cuenta'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
