import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sammseguridad_apk/provider/mainprovider.dart';
import 'package:sammseguridad_apk/services/ApiService.dart';
import 'package:sammseguridad_apk/widgets/Appbar.dart';
import 'package:sammseguridad_apk/widgets/Drawer.dart';

class ScreenHistorialRondas extends StatefulWidget {
  const ScreenHistorialRondas({Key? key}) : super(key: key);
  static const String routeName = '/historialRondas';

  @override
  State<ScreenHistorialRondas> createState() => _ScreenHistorialRondasState();
}

String token = "";

class _ScreenHistorialRondasState extends State<ScreenHistorialRondas> {
  late Future<List<Map<String, dynamic>>> _rondaListFuture;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      final mainProviderSave =
          Provider.of<MainProvider>(context, listen: false);
      final apiService = Provider.of<ApiService>(context, listen: false);

      _rondaListFuture =
          mainProviderSave.getPreferencesToken().then((dataToken) {
        token = dataToken.toString();
        mainProviderSave.updateToken(token);

        return getRondaList(apiService);
      });
    }
  }

  Future<List<Map<String, dynamic>>> getRondaList(ApiService apiService) async {
    var response = await apiService.getData('/rondas/rondas', token);

    if (response is Map<String, dynamic> && response['rondas'] is List) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          isLoading = false;
        });
      });
      return response['rondas'].cast<Map<String, dynamic>>();
    }

    throw Exception("Invalid data format");
  }

  Widget _buildTable(List<Map<String, dynamic>> rondas) {
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
                color: Theme.of(context).colorScheme.secondary, fontSize: 14),
            columns: const <DataColumn>[
              DataColumn(label: Text('Código')),
              DataColumn(label: Text('Descripción')),
              DataColumn(label: Text('Fecha de visita')),
              DataColumn(label: Text('ID')),
            ],
            rows: rondas.map((ronda) {
              return DataRow(cells: <DataCell>[
                DataCell(Text(ronda['Codigo']?.toString() ?? 'N/A')),
                DataCell(Text(ronda['Descripcion']?.toString() ?? 'N/A')),
                DataCell(Text(ronda['FechaVisita']?.toString() ?? 'N/A')),
                DataCell(Text(ronda['Id']?.toString() ?? 'N/A')),
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
                color: (isLoading)
                    ? Color.fromARGB(255, 255, 255, 255)
                    : Color.fromARGB(255, 0, 128, 255).withOpacity(0.2),
              ),
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _rondaListFuture,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    return _buildTable(snapshot.data);
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return const Center(child: CircularProgressIndicator());
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