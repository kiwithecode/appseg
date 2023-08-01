import 'package:flutter/material.dart';
import 'package:sammseguridad_apk/widgets/Appbar.dart';
import 'package:sammseguridad_apk/widgets/Drawer.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sammseguridad_apk/provider/mainprovider.dart';
import 'package:sammseguridad_apk/services/ApiService.dart';

const kAppBarIconColor = Colors.white;
const kMainTextStyle = TextStyle(fontSize: 18);
final kBigTextStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 24);

class ScreanMenu extends StatefulWidget {
  static const String routeName = '/menu';
  const ScreanMenu({Key? key}) : super(key: key);

  @override
  _ScreanMenuState createState() => _ScreanMenuState();
}

class _ScreanMenuState extends State<ScreanMenu> {
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  Map<DateTime, List> _events = {
    DateTime(2023, 7, 7): ['Evento 1'],
    DateTime(2023, 7, 9): ['Evento 2'],
    // Add more dates and events here
  };

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
  }

  Future<List<Map<String, dynamic>>> _getVisitsForSelectedDay(
      DateTime date) async {
    final mainProvider = Provider.of<MainProvider>(context, listen: false);
    final apiService = Provider.of<ApiService>(context, listen: false);

    String token = await mainProvider.getPreferencesToken();
    mainProvider.updateToken(token);

    Map<String, dynamic> requestBody = {
      'date': DateFormat('yyyy-MM-dd').format(date),
    };

    List<Map<String, dynamic>> allVisits = (await apiService.postData(
        '/visitas/viewList', requestBody, token)) as List<Map<String, dynamic>>;

    List<Map<String, dynamic>> visitsForSelectedDay = allVisits.where((visit) {
      DateTime visitDate = DateTime.parse(visit['hora_ingreso']);
      return visitDate.year == date.year &&
          visitDate.month == date.month &&
          visitDate.day == date.day;
    }).toList();

    return visitsForSelectedDay;
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
          ),
        ),
        child: buildBody(),
      ),
    );
  }

  Padding buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildCenterText(
              'Urbanización',
              kBigTextStyle.copyWith(
                  color: Color.fromARGB(255, 255, 255, 255))),
          buildCenterText(
              'Familia Gonzáles - Casa 15A',
              kMainTextStyle.copyWith(
                  color: Color.fromARGB(255, 255, 255, 255))),
          SizedBox(height: 16.0),
          buildCenterText(
            DateFormat('dd MMM yyyy', 'es').format(DateTime.now()),
            kMainTextStyle.copyWith(color: Color.fromARGB(255, 255, 255, 255)),
          ),
          SizedBox(height: 16.0),
          buildCenterText(
              'Registro',
              kMainTextStyle.copyWith(
                  color: Color.fromARGB(255, 255, 255, 255))),
          buildCenterText(
              'Visitas',
              kMainTextStyle.copyWith(
                  color: Color.fromARGB(255, 255, 255, 255))),
          SizedBox(height: 16.0),
          buildTableCalendar(),
        ],
      ),
    );
  }

  Center buildCenterText(String text, TextStyle style) {
    return Center(child: Text(text, style: style));
  }

  Container buildTableCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.all(10),
      child: TableCalendar(
        firstDay: DateTime.utc(2023, 7, 1), // Set first day to July 2023
        lastDay: DateTime.utc(2023, 7, 31), // Set last day to July 2023
        focusedDay: DateTime(2023, 7, 1), // Set focused day to July 1, 2023
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) async {
          if (!isSameDay(_selectedDay, selectedDay)) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });

            // Get visits for selected day
            List<Map<String, dynamic>> visitsForSelectedDay =
                await _getVisitsForSelectedDay(selectedDay);

            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text(
                      'Visitas para ${DateFormat('dd MMMM yyyy', 'es_ES').format(selectedDay)}'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: visitsForSelectedDay.map((visit) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nombres: ${visit['nombre']}'),
                          Text('Apellidos: ${visit['apellido']}'),
                          Text('Hora de Ingreso: ${visit['hora_ingreso']}'),
                          Text('Tiempo: ${visit['duracion']}'),
                          Text('Placa: ${visit['placa']}'),
                        ],
                      );
                    }).toList(),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text('Aceptar'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          }
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        calendarStyle: const CalendarStyle(
          selectedDecoration: BoxDecoration(
            color: Color(0xFF001554),
            shape: BoxShape.circle,
          ),
          selectedTextStyle: TextStyle(color: Colors.white),
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          headerMargin: EdgeInsets.all(0),
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 16),
          leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
          rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (_events[date] != null) {
              return Container(
                width: 20.0,
                height: 20.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                ),
              );
            }
            return Container();
          },
        ),
        eventLoader: (day) {
          return _events[day] ?? [];
        },
      ),
    );
  }
}