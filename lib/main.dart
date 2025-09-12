import 'package:flutter/material.dart';
import 'package:pos_system/pages/order.dart';
import 'pages/login_pos.dart'; //ruta para acceder a la pagina login_pos.dart

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //home: OrderPage(), //vista de ordenes
      home: LoginPos(), //vista de login
    ); // con home:loginPos llamando a la clase LoginPos de login_pos.dart
  }
}
