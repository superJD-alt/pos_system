import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pos_system/pages/panel_meseros.dart';
import 'package:pos_system/screens/main_screen.dart';

class LoginPos extends StatefulWidget {
  const LoginPos({super.key});

  @override
  State<LoginPos> createState() => _LoginPosState();
}

class _LoginPosState extends State<LoginPos> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? errorMessage;
  bool loading = false;

  Future<void> login() async {
    final user = userController.text.trim();
    final pass = passController.text.trim();

    if (user.isEmpty || pass.isEmpty) {
      setState(() => errorMessage = 'Por favor ingrese usuario y contraseña');
      return;
    }

    if (!RegExp(r'^\d+$').hasMatch(user) || !RegExp(r'^\d+$').hasMatch(pass)) {
      setState(() => errorMessage = 'Solo se permiten números');
      return;
    }

    final email =
        '$user@pos.com'; // 👉 convertimos el usuario numérico en email válido

    try {
      setState(() {
        errorMessage = null;
        loading = true;
      });

      await _auth.signInWithEmailAndPassword(email: email, password: pass);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const PanelMeseros(),
          //builder: (context) => const MainScreen(),
        ), //cambiamos ruta dependiendo de quien inicie sesion
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        setState(() => errorMessage = 'Usuario no encontrado');
      } else if (e.code == 'wrong-password') {
        setState(() => errorMessage = 'Contraseña incorrecta');
      } else {
        setState(() => errorMessage = 'Error: ${e.message}');
      }
    } finally {
      setState(() => loading = false);
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
        'assets/images/icon_pos.jpg',
        width: isWide ? size.width * 0.4 : size.width * 0.7,
        height: isWide ? size.width * 0.4 : size.width * 0.7,
        fit: BoxFit.cover,
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
            if (orientation == Orientation.landscape) {
              return Row(
                children: [
                  Expanded(flex: 1, child: Center(child: imageWidget)),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: SingleChildScrollView(child: formWidget),
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
