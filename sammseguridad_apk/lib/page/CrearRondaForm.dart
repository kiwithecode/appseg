import 'package:flutter/material.dart';
import 'package:sammseguridad_apk/widgets/Appbar.dart';
import 'package:sammseguridad_apk/widgets/Drawer.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sammseguridad_apk/services/ApiService.dart';
import 'package:sammseguridad_apk/provider/mainprovider.dart';

const _buttonColor = Color(0xFF0040AE);

class CrearRondaForm extends StatefulWidget {
  final LatLng position;

  CrearRondaForm({required this.position});

  @override
  _CrearRondaFormState createState() => _CrearRondaFormState();
}

class _CrearRondaFormState extends State<CrearRondaForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _observacionesController =
      TextEditingController();
  String _direccionLabel = "";
  String _estado = 'A'; // Default value

  @override
  void initState() {
    super.initState();
    _setInitialAddress();
  }

  Future<void> _setInitialAddress() async {
    try {
      final placemarks = await placemarkFromCoordinates(
        widget.position.latitude,
        widget.position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        setState(() {
          _direccionLabel = [
            place.street,
            place.subLocality,
            place.locality,
            place.administrativeArea,
            place.country,
          ].join(', ');
        });
      }
    } on Exception {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al obtener la dirección inicial'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final mainProvider = Provider.of<MainProvider>(context, listen: false);
        final apiService = Provider.of<ApiService>(context, listen: false);

        String? dataToken = await mainProvider.getPreferencesToken();
        if (dataToken == null) throw Exception("Error al obtener el token");

        String token = dataToken;
        mainProvider.updateToken(token);

        final Map<String, dynamic> data = {
          'coordenadas': "[${widget.position.latitude}, ${widget.position.longitude}]",
          'observaciones': _observacionesController.text,
          'estado': _estado,
          'direccion': _direccionLabel,
        };

       final response =
          await apiService.postData('/rondas/crearRonda', data, token);
      if (response['message'] == 'Ronda creada exitosamente') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Ronda creada exitosamente'),
          backgroundColor: Colors.green,
        ));
        Navigator.of(context).pop(response);
         
        } else {
          throw Exception("Error al crear la ronda");
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$e'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }


  Widget _buildTextField(String label, TextEditingController controller,
      {bool isObscured = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.blue, fontSize: 20.0),
          textAlign: TextAlign.left,
        ),
        SizedBox(height: 10.0),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: label,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(color: Colors.blue),
            ),
          ),
          obscureText: isObscured,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa un texto';
            }
            return null;
          },
        ),
        SizedBox(height: 10.0),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: CustomDrawer(),
      body: Padding(
        padding: EdgeInsets.all(15.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              _buildTextField('Observaciones', _observacionesController),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Estado',
                  style: TextStyle(color: Colors.blue, fontSize: 20.0),
                ),
              ),
              DropdownButtonFormField<String>(
                value: _estado,
                items: <String>['A', 'I'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value == 'A' ? 'Activo' : 'Inactivo'),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _estado = newValue!;
                  });
                },
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Dirección',
                  style: TextStyle(color: Colors.blue, fontSize: 20.0),
                ),
              ),
              Text(_direccionLabel),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _saveForm,
                child: Text(
                  'Guardar',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 80),
                  primary: _buttonColor,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: _buttonColor, width: 2),
                    borderRadius: BorderRadius.circular(0.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
