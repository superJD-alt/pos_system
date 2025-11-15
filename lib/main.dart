import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pos_system/firebase_options.dart';

import 'package:pos_system/pages/order.dart'; //ruta de la pagina de ordenes
import 'pages/login_pos.dart'; //ruta para acceder a la pagina login_pos.dart
import 'pages/custom_table.dart'; //ruta para la pagina de mesas
import 'screens/dashboard.dart'; //ruta para la pagina de dashboard
import 'screens/prueba.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); //inicializacion de Firebase

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //home: CloudinaryTestScreen(productId: 'test_product_123'),
      home: LoginPos(), //vista de login
    );
  }
}
