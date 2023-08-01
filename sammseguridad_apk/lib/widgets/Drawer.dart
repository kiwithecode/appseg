import 'package:flutter/material.dart';
import 'package:sammseguridad_apk/page/PageInfoPropiedad.dart';
import 'package:sammseguridad_apk/page/PageInfoSeguRonda.dart';
import 'package:sammseguridad_apk/page/PageInfoUrba.dart';
import 'package:sammseguridad_apk/page/PageInfoUrbaSeguridad.dart';
import 'package:sammseguridad_apk/page/Perfil.dart';
import 'package:sammseguridad_apk/page/QRView%20.dart';
import 'package:sammseguridad_apk/screens/ScreanMenu.dart';
import 'package:sammseguridad_apk/screens/ScreenGenerarVisita.dart';
import 'package:sammseguridad_apk/screens/ScreenHistorialRondas.dart';
import 'package:sammseguridad_apk/screens/ScreenHistorialVisitas.dart';
import 'package:sammseguridad_apk/screens/ScreenRondas.dart';
import 'package:sammseguridad_apk/screens/ScreenWelcom.dart';

const kDrawerHeaderColor = Color(0xFF0040AE);
final kBigTextStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 24);
final kListTileTextStyle = TextStyle(color: kDrawerHeaderColor, fontSize: 16);

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: kDrawerHeaderColor,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/images/SAMMW.png',
                      width: 110,
                      height: 100,
                    ),
                    SizedBox(width: 100),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PerfilPage(),
                          ),
                        );
                      },
                      child: Icon(
                        Icons.account_circle,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Menú Principal',
                  style: kBigTextStyle.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: kDrawerHeaderColor),
            title: Text('Inicio', style: kListTileTextStyle),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ScreanMenu(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.add, color: kDrawerHeaderColor),
            title: Text('Crear Invitación', style: kListTileTextStyle),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ScreenGenerarVisita(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history, color: kDrawerHeaderColor),
            title: Text('Historial de Invitación', style: kListTileTextStyle),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ScreenHistorialVisitas(),
                ),
              );
            },
          ),
          // ListTile(
          //   leading: const Icon(Icons.maps_home_work, color: kDrawerHeaderColor),
          //   title: Text('Información Urbanización', style: kListTileTextStyle),
          //   onTap: () {
          //     Navigator.of(context).push(
          //       MaterialPageRoute(
          //         builder: (context) => PageInfoUrba(),
          //       ),
          //     );
          //   },
          // ),
          // ListTile(
          //   leading: const Icon(Icons.maps_home_work_sharp, color: kDrawerHeaderColor),
          //   title: Text('Información Propiedad', style: kListTileTextStyle),
          //   onTap: () {
          //     Navigator.of(context).push(
          //       MaterialPageRoute(
          //         builder: (context) => PageInfoPropiedad(),
          //       ),
          //     );
          //   },
          // ),
          ListTile(
            leading: const Icon(Icons.shield, color: kDrawerHeaderColor),
            title: Text('Información Seguridad', style: kListTileTextStyle),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PageInfoUrbaSeguridad(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_police, color: kDrawerHeaderColor),
            title: Text('Crear Rondas', style: kListTileTextStyle),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ScreenRondas(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.work_history, color: kDrawerHeaderColor),
            title: Text('Historial de Rondas', style: kListTileTextStyle),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ScreenHistorialRondas(),
                ),
              );
            },
          ),
            ListTile(
            leading: const Icon(Icons.policy, color: kDrawerHeaderColor),
            title: Text('Seguridad Rondas', style: kListTileTextStyle),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PageInfoSeguRonda(),
                ),
              );
            },
          ),
          ListTile(
            leading:
                const Icon(Icons.qr_code_scanner, color: kDrawerHeaderColor),
            title: Text('Scannear Qr', style: kListTileTextStyle),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => QRViewExample(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: kDrawerHeaderColor),
            title: Text('Cerrar Sesión', style: kListTileTextStyle),
            onTap: () {
               Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ScreenWelcome(),
                ),
              );
              
            },
          ),
        ],
      ),
    );
  }
}
