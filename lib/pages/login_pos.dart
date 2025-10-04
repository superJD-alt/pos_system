import 'package:flutter/material.dart';
import 'package:pos_system/pages/custom_table.dart';

class LoginPos extends StatelessWidget {
  const LoginPos({super.key});

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final size = MediaQuery.of(context).size;
    final bool isWide = size.width > 600;

    // Imagen
    Widget imageWidget = ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.asset(
        'assets/images/icon_pos.jpg',
        width: isWide ? size.width * 0.4 : size.width * 0.7,
        height: isWide ? size.width * 0.4 : size.width * 0.7,
        fit: BoxFit.cover,
      ),
    );

    // Formulario
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
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white10,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 25,
              horizontal: 16,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
            hintText: 'Ingrese su usuario',
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
          obscureText: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white10,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 25,
              horizontal: 16,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
            hintText: 'Ingrese su contraseña',
            hintStyle: const TextStyle(color: Colors.white54, fontSize: 18),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 25),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const CustomTable()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
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
              // 👉 Landscape: fila con imagen izquierda y formulario derecha
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
              // 👉 Portrait: columna con imagen arriba y formulario abajo
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
