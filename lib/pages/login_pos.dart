import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Importaciones de las vistas según el rol
import 'package:pos_system/pages/panel_meseros.dart';
import 'package:pos_system/screens/dashboard.dart';
import 'package:pos_system/pages/mesa_state.dart';

class LoginPos extends StatefulWidget {
  const LoginPos({super.key});

  @override
  State<LoginPos> createState() => _LoginPosState();
}

class _LoginPosState extends State<LoginPos> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final MesaState _mesaState = MesaState();

  String? errorMessage;
  bool loading = false;

  Future<void> login() async {
    final user = userController.text.trim();
    final pass = passController.text.trim();

    if (user.isEmpty || pass.isEmpty) {
      setState(() => errorMessage = 'Por favor ingrese usuario y contraseña');
      return;
    }

    // Validación de solo números
    if (!RegExp(r'^\d+$').hasMatch(user) || !RegExp(r'^\d+$').hasMatch(pass)) {
      setState(() => errorMessage = 'Solo se permiten números');
      return;
    }

    // Construcción del email para Firebase Auth
    final email = '$user@pos.com';

    try {
      setState(() {
        errorMessage = null;
        loading = true;
      });

      // 1. Autenticar usuario
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );

      // 2. Obtener el documento del usuario para nombre y rol
      String nombreMesero = "Usuario POS";
      String userRole = 'unknown';

      if (userCredential.user != null) {
        try {
          DocumentSnapshot userDoc = await _firestore
              .collection('usuarios')
              .doc(userCredential.user!.uid)
              .get();

          if (userDoc.exists) {
            // Obtener nombre y rol
            nombreMesero = userDoc.get('nombre') ?? "Usuario #$user";
            userRole =
                (userDoc.get('rol') as String?)?.toLowerCase() ?? 'unknown';

            // ✅ ACTUALIZAR sesionActiva a true
            await _firestore
                .collection('usuarios')
                .doc(userCredential.user!.uid)
                .update({'sesionActiva': true});

            debugPrint('✅ Usuario autenticado. Rol: $userRole');
            debugPrint('✅ Sesión marcada como activa');
          } else {
            debugPrint(
              'Error: Documento de usuario no encontrado en Firestore.',
            );
            userRole = 'unregistered';
          }
        } catch (e) {
          debugPrint('Error al obtener datos del usuario (nombre/rol): $e');
          userRole = 'error_fetching_role';
        }
      }

      // 3. GUARDAR el nombre en MesaState
      _mesaState.establecerMesero(nombreMesero);
      debugPrint('✅ Mesero/Usuario establecido: $nombreMesero');

      if (!mounted) return;

      // 4. Lógica de navegación condicional por rol
      Widget destinationPage;

      switch (userRole) {
        case 'mesero':
        case 'cocinero':
          destinationPage = const PanelMeseros();
          break;
        case 'administrador':
        case 'cajero':
          destinationPage = const Dashboard();
          break;
        default:
          await _auth.signOut();
          setState(() {
            errorMessage =
                'Rol de usuario no válido o no asignado. No se puede acceder al sistema.';
            loading = false;
          });
          return;
      }

      // Navegar a la página determinada
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => destinationPage),
      );
    } on FirebaseAuthException catch (e) {
      String msg;
      if (e.code == 'user-not-found' || e.code == 'invalid-email') {
        msg = 'Usuario no encontrado';
      } else if (e.code == 'wrong-password') {
        msg = 'Contraseña incorrecta';
      } else {
        msg = 'Error de autenticación: ${e.message}';
      }
      setState(() => errorMessage = msg);
      debugPrint('Error de Auth: ${e.message}');
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final size = MediaQuery.of(context).size;
    final bool isWide = size.width > 600;

    Widget imageWidget = ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.asset(
        'assets/images/icon_pos.png',
        width: isWide ? size.width * 0.4 : size.width * 0.7,
        height: isWide ? size.width * 0.4 : size.width * 0.7,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: isWide ? size.width * 0.4 : size.width * 0.7,
            height: isWide ? size.width * 0.4 : size.width * 0.7,
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.restaurant_menu,
              color: Colors.white70,
              size: 80,
            ),
          );
        },
      ),
    );

    Widget formWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'Login',
            style: TextStyle(
              color: Colors.white,
              fontSize: isWide ? 64 : 42,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 15),
        Text(
          'Usuario:',
          style: TextStyle(
            color: Colors.white,
            fontSize: isWide ? 32 : 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: userController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white10,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
            hintText: 'Ingrese su usuario (solo números)',
            hintStyle: const TextStyle(color: Colors.white54, fontSize: 18),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 20),
        Text(
          'Contraseña:',
          style: TextStyle(
            color: Colors.white,
            fontSize: isWide ? 32 : 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: passController,
          obscureText: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white10,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
            hintText: 'Ingrese su contraseña',
            hintStyle: const TextStyle(color: Colors.white54, fontSize: 18),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 25),

        if (errorMessage != null)
          Center(
            child: Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent, fontSize: 16),
            ),
          ),

        const SizedBox(height: 10),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: loading ? null : login,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 5,
            ),
            child: loading
                ? const CircularProgressIndicator(color: Colors.black)
                : Text(
                    'Iniciar Sesión',
                    style: TextStyle(
                      fontSize: isWide ? 22 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (orientation == Orientation.landscape &&
                constraints.maxWidth > 800) {
              return Row(
                children: [
                  Expanded(flex: 1, child: Center(child: imageWidget)),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 500),
                          child: SingleChildScrollView(child: formWidget),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Center(child: imageWidget),
                      const SizedBox(height: 20),
                      formWidget,
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
