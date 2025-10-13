import 'package:flutter/material.dart';
import 'package:pos_system/pages/custom_table.dart';
import 'package:pos_system/pages/pedidos_activos.dart';

class PanelMeseros extends StatelessWidget {
  const PanelMeseros({super.key});

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
              padding: const EdgeInsets.only(top: 40.0), // Espacio desde el top
              child: Column(
                children: [
                  // 🔹 Aquí puedes agregar tu label de bienvenida
                  const Text(
                    'Hola, [Nombre Usuario]',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 40), // Espacio entre label y botones
                  // 🔹 Fila con los tres botones principales
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔹 Botón 1
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

                      // 🔹 Botón 2
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PedidosActivos(),
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

                      // 🔹 Botón 3
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
                      debugPrint('Botón inferior presionado');
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

                  const SizedBox(height: 80), // Espacio extra al final
                ],
              ),
            ),
          ),

          // 🔹 Botón "Cerrar sesión" flotante en esquina inferior derecha
          Positioned(
            bottom: 32,
            right: 32,
            child: ElevatedButton(
              onPressed: () {
                debugPrint('Cerrar sesión presionado');
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
}
