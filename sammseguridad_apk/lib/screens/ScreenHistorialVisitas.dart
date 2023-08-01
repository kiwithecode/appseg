import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sammseguridad_apk/provider/mainprovider.dart';
import 'package:sammseguridad_apk/services/ApiService.dart';
import 'package:sammseguridad_apk/widgets/Appbar.dart';
import 'package:sammseguridad_apk/widgets/Drawer.dart';

class ScreenHistorialVisitas extends StatefulWidget {
  const ScreenHistorialVisitas({Key? key}) : super(key: key);
  static const String routeName = '/historial';

  @override
  State<ScreenHistorialVisitas> createState() => _ScreenHistorialVisitasState();
}

String token = "";

class _ScreenHistorialVisitasState extends State<ScreenHistorialVisitas> {
  late Future<List<Map<String, dynamic>>> _visitaListFuture;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      final mainProviderSave =
          Provider.of<MainProvider>(context, listen: false);
      final apiService = Provider.of<ApiService>(context, listen: false);

      _visitaListFuture =
          mainProviderSave.getPreferencesToken().then((dataToken) {
        token = dataToken.toString();
        mainProviderSave.updateToken(token);

        return getVisitaList(apiService);
      });
    }
  }

  Future<List<Map<String, dynamic>>> getVisitaList(
      ApiService apiService) async {
    var response = await apiService.getData('/visitas/lista', token);

    // Verifica si la respuesta es una lista
    if (response is List) {
      // Asegúrate de que cada elemento de la lista es un Map<String, dynamic>
      return response.cast<Map<String, dynamic>>();
    }

    // Si no es una lista, lanza una excepción o maneja este caso de manera apropiada
    throw Exception("Invalid data format");
  }

  Widget _buildTable(List<Map<String, dynamic>> visitas) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 16.0,
            headingTextStyle: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.bold),
            dataTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 14), // Cambio aquí
            columns: const <DataColumn>[
              DataColumn(label: Text('Codigo')),
              DataColumn(label: Text('Descripcion')),
              DataColumn(label: Text('Duracion')),
              DataColumn(label: Text('Estado')),
              DataColumn(label: Text('FechaCrea')),
              DataColumn(label: Text('FechaVisita')),
              DataColumn(label: Text('Hora')),
              DataColumn(label: Text('Placa')),
            ],
            rows: visitas.map((visita) {
              return DataRow(cells: <DataCell>[
                DataCell(Text(visita['Codigo']?.toString() ?? 'N/A')),
                DataCell(Text(visita['Descripcion']?.toString() ?? 'N/A')),
                DataCell(Text(visita['Duracion']?.toString() ?? 'N/A')),
                DataCell(Text(visita['Estado']?.toString() ?? 'N/A')),
                DataCell(Text(visita['FechaCrea']?.toString() ?? 'N/A')),
                DataCell(Text(visita['FechaVisita']?.toString() ?? 'N/A')),
                DataCell(Text(visita['Hora']?.toString() ?? 'N/A')),
                DataCell(Text(visita['Placa']?.toString() ?? 'N/A')),
              ]);
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: CustomDrawer(),
      body: Column(
        children: [
          SizedBox(height: 20.0),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Color(0xFF0040AE).withOpacity(0.2),
              ),
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _visitaListFuture,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    return _buildTable(snapshot.data);
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}