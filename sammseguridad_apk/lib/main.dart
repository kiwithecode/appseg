import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sammseguridad_apk/provider/mainprovider.dart';
import 'package:sammseguridad_apk/screens/ScreanMenu.dart';
import 'package:sammseguridad_apk/screens/ScreenHistorialVisitas.dart';
import 'package:sammseguridad_apk/screens/logins/ScreenFaceID_Huella.dart';
import 'package:sammseguridad_apk/screens/logins/ScreenLogin.dart';
import 'package:sammseguridad_apk/screens/crear/ScreenCreascuenta.dart';

import 'screens/logins/ScreenLoginPin.dart';
import 'screens/ScreenSplash.dart';
import 'services/ApiService.dart';

import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>(
          create: (_) => ApiService(),
        ),
        ChangeNotifierProvider(
          create: (_) => MainProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SAMM',
      initialRoute: ScreenSplash.routeName,
      routes: {
        LoginPage.routeName: (context) => const LoginPage(),
        ScreenLoginPin.routeName: (context) => const ScreenLoginPin(),
        ScreenFaceID_Huella.routeName: (context) => const ScreenFaceID_Huella(),
        ScreenSplash.routeName: (context) => const ScreenSplash(),
        ScreanMenu.routeName: (context) => const ScreanMenu(),
        ScreenHistorialVisitas.routeName: (context) =>
            ChangeNotifierProvider<MainProvider>(
              create: (_) => MainProvider(),
              child: const ScreenHistorialVisitas(),
            ),
        'register': (context) => ScreenCreascuenta(), // Agrega esta línea
      },
    );
  }
}