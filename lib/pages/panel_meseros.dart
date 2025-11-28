import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pos_system/pages/pedidos_activos.dart';
import 'package:pos_system/pages/login_pos.dart'; //ruta para acceder a la pagina login_pos.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pos_system/pages/view_table.dart';
import 'package:pos_system/pages/custom_table.dart';
import 'package:pos_system/pages/resumen_turno_page.dart';
import 'package:pos_system/pages/apartadoBotellaPage.dart';

class PanelMeseros extends StatefulWidget {
  const PanelMeseros({super.key});

  @override
  State<PanelMeseros> createState() => _PanelMeserosState();
}

class _PanelMeserosState extends State<PanelMeseros> {
  String nombreMesero = 'Cargando...';

  @override
  void initState() {
    super.initState();
    testFirestore(); // Llama aquí la función de prueba
    obtenerNombreMesero();
  }

  // 🔹 Función para obtener el nombre del mesero desde Firestoreq
  Future<void> obtenerNombreMesero() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        setState(() {
          nombreMesero = doc['nombre'] ?? 'Mesero';
        });
      } else {
        setState(() {
          nombreMesero = user.displayName ?? 'Mesero';
        });
      }
    } else {
      setState(() {
        nombreMesero = 'Invitado';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Meseros'),
        backgroundColor: Colors.indigoAccent,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Contenido principal
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Column(
                children: [
                  // 🔹 Mostrar el nombre real del mesero
                  Text(
                    'Hola, $nombreMesero 👋',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 🔹 Fila con los tres botones principales
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔹 Botón 1 - Nuevo pedido
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CustomTable(),
                                ),
                              );
                            },
                            label: const Text(''),
                            icon: const Icon(Icons.add, size: 250),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              side: const BorderSide(
                                color: Colors.black,
                                width: 8.0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Nuevo pedido',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      // 🔹 Botón 2 - Pedidos activos
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const PedidosActivosPage(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.restaurant, size: 250),
                            label: const Text(''),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              side: const BorderSide(
                                color: Colors.black,
                                width: 8.0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Pedidos activos',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      // 🔹 Botón 3 - Mesas
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ViewTable(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.table_restaurant, size: 250),
                            label: const Text(''),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.yellow,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              side: const BorderSide(
                                color: Colors.black,
                                width: 8.0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Mesas',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 60),

                  // 🔹 Botón Resumen del turno
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ResumenTurnoPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 60,
                        vertical: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Resumen del turno',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          // 🔹 Botón "Apartado Botellas"
          Positioned(
            bottom: 20, // Mismo valor que "Cerrar sesión"
            left: 40, // Posicionamiento en el lado izquierdo
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const apartadoBotellaPage(), // <-- Sustituye esta línea
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 60,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Apartado Botellas',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // 🔹 Botón "Cerrar sesión"
          Positioned(
            bottom: 20,
            right: 32,
            child: ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPos()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 60,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Cerrar sesión',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //
  void testFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          print('Documento encontrado: ${doc.data()}');
        } else {
          print('Documento NO encontrado. Revisa el UID.');
        }
      } else {
        print('No hay usuario logueado.');
      }
    } catch (e) {
      print('Error al conectar con Firestore: $e');
    }
  }
}
