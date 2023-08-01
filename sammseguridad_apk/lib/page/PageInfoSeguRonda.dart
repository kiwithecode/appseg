import 'package:flutter/material.dart';
import 'package:sammseguridad_apk/page/PageGPS.dart';
import 'package:sammseguridad_apk/widgets/Appbar.dart';
import 'package:sammseguridad_apk/widgets/Drawer.dart';
import 'package:provider/provider.dart';
import 'package:sammseguridad_apk/services/ApiService.dart';
import 'package:sammseguridad_apk/provider/mainprovider.dart';

String token = "";

class PageInfoSeguRonda extends StatefulWidget {
  @override
  _PageInfoSeguRondaState createState() => _PageInfoSeguRondaState();
}

class _PageInfoSeguRondaState extends State<PageInfoSeguRonda> {
  late Future<List<Map<String, dynamic>>> _personasListFuture;
  final textStyle = TextStyle(fontSize: 16.0, color: Color(0xff297DE2));

  @override
  void initState() {
    super.initState();
    final mainProviderSave = Provider.of<MainProvider>(context, listen: false);
    final apiService = Provider.of<ApiService>(context, listen: false);

    _personasListFuture =
        mainProviderSave.getPreferencesToken().then((dataToken) {
      token = dataToken.toString();
      mainProviderSave.updateToken(token);

      return getPersonasList(apiService);
    });
  }

  Future<List<Map<String, dynamic>>> getPersonasList(
      ApiService apiService) async {
    var response = await apiService.getData('/visitas/personas/Guardia', token);

    if (response is Map<String, dynamic>) {
      if (response['personas'] is List) {
        return response['personas'].cast<Map<String, dynamic>>();
      }
    }

    throw Exception("Invalid data format");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: CustomDrawer(),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/FOTO-1.jpg'),
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _personasListFuture,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              List<Map<String, dynamic>> personas = snapshot.data;
              return ListView.builder(
                itemCount: personas.length,
                itemBuilder: (BuildContext context, int index) {
                  return _buildCard(personas[index]);
                },
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

Widget _buildCard(Map<String, dynamic> persona) {
    return Container(
      padding: EdgeInsets.all(10.0),
      margin: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  image: DecorationImage(
                    image: AssetImage('assets/images/SAMM.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Guardia',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18.0,
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Nombre: ${persona['nombres'] ?? '-'}',
                      textAlign: TextAlign.center,
                      style: textStyle,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Cédula: ${persona['cedula'] ?? '-'}',
                      textAlign: TextAlign.center,
                      style: textStyle,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Teléfono: ${persona['tel_celular'] ?? '-'}',
                      textAlign: TextAlign.center,
                      style: textStyle,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Estado: ${persona['estado'] ?? '-'}',
                      textAlign: TextAlign.start,
                      style: textStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PageGPS()),
              );
            },
            child: Text('Detalle de la Ronda'),
          ),
        ],
      ),
    );
  }


}