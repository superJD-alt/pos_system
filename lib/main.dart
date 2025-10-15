import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pos_system/firebase_options.dart';

import 'package:pos_system/pages/order.dart'; //ruta de la pagina de ordenes
import 'pages/login_pos.dart'; //ruta para acceder a la pagina login_pos.dart
import 'pages/custom_table.dart'; //ruta para la pagina de mesas

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); //inicializacion de Firebase
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
    );
  }
}
