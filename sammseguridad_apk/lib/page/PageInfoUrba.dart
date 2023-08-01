import 'package:flutter/material.dart';
import 'package:sammseguridad_apk/widgets/Appbar.dart';
import 'package:sammseguridad_apk/widgets/Drawer.dart';

class PageInfoUrba extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: CustomAppBar(),
      drawer: CustomDrawer(),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/FOTO-1.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(10.0),
            margin: EdgeInsets.all(20.0), // Agregando margen alrededor del Container
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: ListView(
              shrinkWrap: true,
              children: [
                SizedBox(height: 20,),
                Text(
                  'Información',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30.0, color: Color(0xFF0040AE)),
                ),
                SizedBox(height: 10,),
                Text(
                  'Urbanización',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25.0, color: Color(0xFF001554)),
                ),
                SizedBox(height: 40,),
                Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    image: DecorationImage(
                      image: AssetImage('assets/images/SAMM.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                Text(
                  'Urbanización Pacho Salas',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20.0, color : Color(0xff297DE2)),
                ),
                SizedBox(height: 20,),
                Text(
                  'Ubicación: Texto',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18.0, color : Color(0xff297DE2)),
                ),
                SizedBox(height: 20,),
                Text(
                  'Casas: Texto',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18.0, color : Color(0xff297DE2)),
                ),
                SizedBox(height: 20,),
                Text(
                  'Conjuntos: Texto',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18.0, color : Color(0xff297DE2)),
                ),
                SizedBox(height: 40,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
