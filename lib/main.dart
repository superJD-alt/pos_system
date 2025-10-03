import 'package:flutter/material.dart';

import 'package:pos_system/pages/order.dart'; //ruta de la pagina de ordenes
import 'pages/login_pos.dart'; //ruta para acceder a la pagina login_pos.dart
import 'pages/custom_table.dart'; //ruta para la pagina de mesas

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //home: CustomTable(),
      //home: OrderPage(), //vista de ordenes
      home: LoginPos(), //vista de login
    ); // con home:loginPos llamando a la clase LoginPos de login_pos.dart
  }
}
