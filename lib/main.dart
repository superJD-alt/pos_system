import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pos_system/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pos_system/pages/order.dart';
import 'pages/login_pos.dart';
import 'pages/custom_table.dart';
import 'screens/dashboard.dart';
import 'screens/prueba.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);

  // 1. Inicialización de Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 2. Lógica Inteligente de Orientación
  await _configurarOrientacionSegunDispositivo();

  // 3. Configurar persistencia de sesión: SOLO si es plataforma WEB
  if (kIsWeb) {
    try {
      await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
      debugPrint("Persistencia de Auth configurada para Web.");
    } catch (e) {
      debugPrint("Error al configurar la persistencia web: $e");
    }
  }

  runApp(const MyApp());
}

/// Detecta si es tablet o celular y bloquea la orientación correspondiente
Future<void> _configurarOrientacionSegunDispositivo() async {
  // Obtenemos los datos de la pantalla directamente desde el dispatcher
  final dispatcher = WidgetsBinding.instance.platformDispatcher;
  final view = dispatcher.views.first;

  // Calculamos las dimensiones lógicas
  final double width = view.physicalSize.width / view.devicePixelRatio;
  final double height = view.physicalSize.height / view.devicePixelRatio;

  // El lado más corto define si es tablet (>= 600dp) o celular (< 600dp)
  final double shortestSide = width < height ? width : height;

  if (shortestSide >= 600) {
    // TABLET: Modo Horizontal
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    debugPrint(
      "📱 TABLET detectada (Shortest side: ${shortestSide.toStringAsFixed(2)}dp) -> Horizontal",
    );
  } else {
    // CELULAR: Modo Vertical
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    debugPrint(
      "📱 CELULAR detectado (Shortest side: ${shortestSide.toStringAsFixed(2)}dp) -> Vertical",
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'POS System',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const LoginPos(), // O la página que tengas por defecto
    );
  }
}
