import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      backgroundColor: Color(0xFF0040AE), // Estableciendo el color del AppBar
      title: GestureDetector(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 150,
            height: 50,
            child: Image.asset("assets/images/SAMMW.png"),
          ),
        ),
      ),
    );
  }
}
