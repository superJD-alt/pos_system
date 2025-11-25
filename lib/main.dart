import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pos_system/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pos_system/pages/order.dart'; //ruta de la pagina de ordenes
import 'pages/login_pos.dart'; //ruta para acceder a la pagina login_pos.dart
import 'pages/custom_table.dart'; //ruta para la pagina de mesas
import 'screens/dashboard.dart'; //ruta para la pagina de dashboard
import 'screens/prueba.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);

  // 1. Inicialización de Firebase (SOLO UNA VEZ y con options)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // 2. Configurar persistencia de sesión: SOLO si es plataforma WEB
  // En plataformas nativas (iOS, Android, Desktop), la persistencia es automática.
  if (kIsWeb) {
    try {
      await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
      debugPrint("Persistencia de Auth configurada para Web.");
    } catch (e) {
      debugPrint("Error al configurar la persistencia web: $e");
    }
  }

  // ❌ Se eliminó la línea "await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);"
  //    que no estaba envuelta en el 'if (kIsWeb)' y causaba el UnimplementedError.

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
