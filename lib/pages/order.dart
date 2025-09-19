import 'package:flutter/material.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  String categoriaSeleccionada = "Alimentos"; // valor inicial

  // Productos: solo nombres, para botones sin imagen
  final Map<String, List<String>> productos = {
    "Alimentos": ["Hamburguesa", "Pizza", "Papas Fritas"],
    "Bebidas": ["Coca-Cola", "Agua", "Jugo"],
    "Postres": ["Helado", "Pastel", "Galletas"],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Column(
        children: [
          // ================== HEADER SUPERIOR ==================
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Container(
              height: 70,
              width: double.infinity,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 5),

          // ================== FILA PRINCIPAL ==================
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ========== LADO IZQUIERDO ==========
                  Expanded(
                    child: Column(
                      children: [
                        // ===== TABLA DE ORDENES (AZUL) =====
                        Container(
                          height: 450,
                          color: Colors.blue,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: DataTable(
                              headingRowColor: MaterialStateProperty.all(
                                Colors.grey[200],
                              ),
                              border: TableBorder.symmetric(),
                              columns: const [
                                DataColumn(label: Text('Cant')),
                                DataColumn(label: Text('C')),
                                DataColumn(label: Text('Descripción')),
                                DataColumn(label: Text('Precio')),
                                DataColumn(label: Text('Total')),
                              ],
                              rows: const [
                                DataRow(
                                  cells: [
                                    DataCell(Text('2')),
                                    DataCell(Text('*')),
                                    DataCell(Text('Hamburguesa')),
                                    DataCell(Text('\$5.00')),
                                    DataCell(Text('\$10.00')),
                                  ],
                                ),
                                DataRow(
                                  cells: [
                                    DataCell(Text('1')),
                                    DataCell(Text('/')),
                                    DataCell(Text('Papas Fritas')),
                                    DataCell(Text('\$3.00')),
                                    DataCell(Text('\$3.00')),
                                  ],
                                ),
                                DataRow(
                                  cells: [
                                    DataCell(Text('3')),
                                    DataCell(Text('*')),
                                    DataCell(Text('Refresco')),
                                    DataCell(Text('\$2.00')),
                                    DataCell(Text('\$6.00')),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 5),

                        // ===== CONTENEDOR TOTAL (ROJO) =====
                        Container(height: 60, color: Colors.red),

                        const SizedBox(height: 5),

                        // ===== BOTONES =====
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.note),
                              label: const Text('NOTA'),
                              style: _botonEstilo(),
                            ),
                            const SizedBox(width: 5),
                            ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.cancel),
                              label: const Text('CANCELAR'),
                              style: _botonEstilo(),
                            ),
                            const SizedBox(width: 5),
                            ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.access_time),
                              label: const Text('TIEMPOS'),
                              style: _botonEstilo(),
                            ),
                            const SizedBox(width: 5),
                            ElevatedButton(
                              onPressed: () {},
                              style: _botonEstilo(minWidth: 50),
                              child: const Icon(Icons.delete, size: 30),
                            ),
                          ],
                        ),

                        const SizedBox(height: 5),

                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.arrow_forward),
                              label: const Text('MOVER'),
                              style: _botonEstilo(),
                            ),
                            const SizedBox(width: 5),
                            _botonNumero('1'),
                            const SizedBox(width: 5),
                            _botonNumero('2'),
                            const SizedBox(width: 5),
                            _botonNumero('3'),
                            const SizedBox(width: 5),
                            _botonNumero('+', minWidth: 75),
                          ],
                        ),

                        const SizedBox(height: 5),

                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {},
                              label: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text('IMPRIMIR'),
                                  Text('COMANDA'),
                                ],
                              ),
                              style: _botonEstilo(),
                            ),
                            const SizedBox(width: 5),
                            _botonNumero('4'),
                            const SizedBox(width: 5),
                            _botonNumero('5'),
                            const SizedBox(width: 5),
                            _botonNumero('6'),
                            const SizedBox(width: 5),
                            _botonNumero('-', minWidth: 75),
                          ],
                        ),

                        const SizedBox(height: 5),

                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {},
                              label: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text('IMPRIMIR'),
                                  Text('CUENTA'),
                                ],
                              ),
                              style: _botonEstilo(),
                            ),
                            const SizedBox(width: 5),
                            _botonNumero('7'),
                            const SizedBox(width: 5),
                            _botonNumero('8'),
                            const SizedBox(width: 5),
                            _botonNumero('9'),
                            const SizedBox(width: 5),
                            _botonNumero('0', minWidth: 75),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  // ========== LADO DERECHO ==========
                  Column(
                    children: [
                      // contenedor rosa (arriba)
                      Container(
                        height: 60,
                        width: 700,
                        color: Colors.pink,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _categoriaBoton('Entradas'),
                            _categoriaBoton('Ensaladas'),
                            _categoriaBoton('Sopas'),
                            _categoriaBoton('Comida'),
                            _categoriaBoton('Postres'),
                            _categoriaBoton('Bebidas'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      // contenedor café (debajo del rosa)
                      Container(
                        height: 610,
                        width: 700,
                        color: Colors.brown,
                        padding: const EdgeInsets.all(10),
                        child: GridView.builder(
                          itemCount:
                              productos[categoriaSeleccionada]?.length ?? 0,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 2,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                              ),
                          itemBuilder: (context, index) {
                            final producto =
                                productos[categoriaSeleccionada]![index];
                            return ElevatedButton(
                              onPressed: () {
                                print("Presionaste $producto");
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                  Colors.white,
                                ),
                                foregroundColor: MaterialStateProperty.all(
                                  Colors.black,
                                ),
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              child: Text(
                                producto,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== Helpers para botones =====
  ButtonStyle _botonEstilo({double minWidth = 130}) {
    return ButtonStyle(
      minimumSize: MaterialStateProperty.all(Size(minWidth, 50)),
      backgroundColor: MaterialStateProperty.all(Colors.white),
      foregroundColor: MaterialStateProperty.all(Colors.black),
      alignment: Alignment.center,
      shape: MaterialStateProperty.all(
        const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
    );
  }

  Widget _botonNumero(String texto, {double minWidth = 90}) {
    return ElevatedButton(
      onPressed: () {},
      style: _botonEstilo(minWidth: minWidth),
      child: Text(texto, style: const TextStyle(fontSize: 20)),
    );
  }

  // 🔹 BOTÓN DE CATEGORÍA (solo texto)
  Widget _categoriaBoton(String nombre) {
    final bool seleccionado = categoriaSeleccionada == nombre;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 15),
      child: GestureDetector(
        onTap: () {
          setState(() {
            categoriaSeleccionada = nombre;
          });
        },
        child: Container(
          width: 120,
          decoration: BoxDecoration(
            color: seleccionado ? Colors.white : Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: seleccionado ? Colors.blue : Colors.transparent,
              width: 2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            nombre,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: seleccionado ? Colors.black : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }
}
