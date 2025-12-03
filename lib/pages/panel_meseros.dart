import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pos_system/pages/pedidos_activos.dart';
import 'package:pos_system/pages/login_pos.dart';
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
    testFirestore();
    obtenerNombreMesero();
  }

  // 🔹 Función para obtener el nombre del mesero desde Firestore
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
          // Contenido principal (Scrollable)
          SingleChildScrollView(
            // Añadir un padding extra al final para asegurar que los
            // botones fijos del Stack no tapen el contenido.
            padding: const EdgeInsets.only(
              top: 40.0,
              bottom: 150.0,
            ), // <-- AUMENTO DEL BUFFER
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
                    _buildMainMenuButton(
                      context,
                      title: 'Nuevo pedido',
                      icon: Icons.add,
                      color: Colors.green,
                      page: const CustomTable(),
                    ),

                    // 🔹 Botón 2 - Pedidos activos
                    _buildMainMenuButton(
                      context,
                      title: 'Pedidos activos',
                      icon: Icons.restaurant,
                      color: Colors.blue,
                      page: const PedidosActivosPage(),
                    ),

                    // 🔹 Botón 3 - Mesas
                    _buildMainMenuButton(
                      context,
                      title: 'Mesas',
                      icon: Icons.table_restaurant,
                      color: Colors.yellow,
                      page: const ViewTable(),
                    ),
                  ],
                ),

                const SizedBox(height: 60),

                // 🔹 Botón Resumen del turno
                _buildLargeActionButton(
                  context,
                  title: 'Resumen del turno',
                  color: Colors.orange,
                  page: const ResumenTurnoPage(),
                ),
              ],
            ),
          ),

          // 🔹 Botón "Apartado Botellas" (Posición Fija)
          Positioned(
            bottom:
                32, // Alineación ajustada a 32 para que coincida con Cerrar Sesión
            left: 32, // Posición fija izquierda
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const apartadoBotellaPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
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

          // 🔹 Botón "Cerrar sesión" (Posición Fija)
          Positioned(
            bottom: 32,
            right: 32,
            child: ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPos()),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
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

          // El botón de cocina se movió al SingleChildScrollView
        ],
      ),
    );
  }

  // Widget helper para los 3 botones grandes superiores
  Widget _buildMainMenuButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required Widget page,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => page),
            );
          },
          label: const Text(''),
          icon: Icon(icon, size: 250),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            side: const BorderSide(color: Colors.black, width: 8.0),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // Widget helper para los botones de acción centrales
  Widget _buildLargeActionButton(
    BuildContext context, {
    required String title,
    required Color color,
    required Widget page,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void testFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          debugPrint('Documento encontrado: ${doc.data()}');
        } else {
          debugPrint('Documento NO encontrado. Revisa el UID.');
        }
      } else {
        debugPrint('No hay usuario logueado.');
      }
    } catch (e) {
      debugPrint('Error al conectar con Firestore: $e');
    }
  }
}
