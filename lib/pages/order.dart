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
              child: Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('ATRÁS'),
                    style: _botonEstilo(minWidth: 150, minHeight: 60),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.menu, size: 30),
                    label: const Text(''),
                    style: _botonEstilo(minWidth: 150, minHeight: 60),
                  ),
                ],
              ),
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
                    flex: 1,
                    child: Column(
                      children: [
                        // ===== TABLA DE ORDENES =====
                        Expanded(
                          child: Container(
                            color: Colors.grey[100],
                            width: double.infinity,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(
                                  Colors.grey[400],
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
                        ),

                        const SizedBox(height: 5),

                        // ===== CONTENEDOR TOTAL =====
                        Container(
                          height: 80,
                          padding: const EdgeInsets.all(5),
                          margin: EdgeInsets.zero,
                          //margin: const EdgeInsets.symmetric(vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    "Total de ítems:",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 80,
                                  ), // Espacio entre el texto y el campo
                                  Expanded(
                                    child: TextField(
                                      readOnly: true,
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 7),
                              Row(
                                children: [
                                  const Text(
                                    "Total:",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 80,
                                  ), // Espacio entre el texto y el campo
                                  Expanded(
                                    child: TextField(
                                      readOnly: true,
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        //const SizedBox(height: 1),

                        // ===== TECLADO POS COMPLETO =====
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.zero,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final buttonHeight =
                                    (constraints.maxHeight - 25) / 5;
                                final buttonWidth =
                                    (constraints.maxWidth - 15) / 4;

                                final botones = [
                                  _botonAccion(
                                    Icons.local_offer,
                                    "NOTA",
                                    () {},
                                  ),
                                  _botonAccion(Icons.cancel, "CANCELAR", () {}),
                                  _botonAccion(
                                    Icons.access_time,
                                    "TIEMPOS",
                                    () {},
                                  ),
                                  _botonAccion(Icons.backspace, "", () {}),

                                  _botonAccion(
                                    Icons.swap_horiz,
                                    "TRANSFERIR",
                                    () {},
                                  ),
                                  _botonNumero("1"),
                                  _botonNumero("2"),
                                  _botonNumero("3"),

                                  _botonAccion(Icons.print, "COMANDA", () {}),
                                  _botonNumero("4"),
                                  _botonNumero("5"),
                                  _botonNumero("6"),

                                  _botonAccion(
                                    Icons.receipt_long,
                                    "CUENTA",
                                    () {},
                                  ),
                                  _botonNumero("7"),
                                  _botonNumero("8"),
                                  _botonNumero("9"),

                                  _botonAccion(Icons.check, "ENTER", () {}),
                                  _botonNumero("0"),
                                  _botonNumero("."),
                                  const SizedBox.shrink(), // Espacio vacío
                                ];
                                return GridView.count(
                                  crossAxisCount: 4,
                                  mainAxisSpacing: 5,
                                  crossAxisSpacing: 5,
                                  childAspectRatio: buttonWidth / buttonHeight,
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: botones,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10), // Espacio entre los dos lados
                  // ========== LADO DERECHO ==========
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Container(
                          height: 60,
                          color: Colors.grey[300],
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _categoriaBoton('Entradas'),
                              _categoriaBoton('Ensaladas'),
                              _categoriaBoton('Sopas'),
                              _categoriaBoton('Comida'),
                              _categoriaBoton('Postres'),
                              _categoriaBoton('Bebidas'),
                              _categoriaBoton('Buscar..', icono: Icons.search),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Expanded(
                          child: Container(
                            color: Colors.grey[300],
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
                                    backgroundColor: WidgetStateProperty.all(
                                      Colors.white,
                                    ),
                                    foregroundColor: WidgetStateProperty.all(
                                      Colors.black,
                                    ),
                                    shape: WidgetStateProperty.all(
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
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== Helpers =====
  ButtonStyle _botonEstilo({double minWidth = 120, double minHeight = 60}) {
    return ButtonStyle(
      minimumSize: WidgetStateProperty.all(Size(minWidth, minHeight)),
      backgroundColor: WidgetStateProperty.all(Colors.white),
      foregroundColor: WidgetStateProperty.all(Colors.black),
      alignment: Alignment.center,
      shape: WidgetStateProperty.all(
        const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
    );
  }

  Widget _botonNumero(String texto) {
    return ElevatedButton(
      onPressed: () {},
      style: _botonEstilo(),
      child: Text(texto, style: const TextStyle(fontSize: 20)),
    );
  }

  Widget _botonAccion(IconData icono, String texto, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: _botonEstilo(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icono, size: 24),
          if (texto.isNotEmpty)
            FittedBox(
              child: Text(
                texto,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _categoriaBoton(String nombre, {IconData? icono}) {
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
          width: 95,
          decoration: BoxDecoration(
            color: seleccionado ? Colors.white : Colors.grey[300],
            borderRadius: BorderRadius.circular(1),
            border: Border.all(
              color: seleccionado ? Colors.blue : Colors.transparent,
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icono != null) ...[
                Icon(
                  icono,
                  size: 20,
                  color: seleccionado ? Colors.black : Colors.grey[700],
                ),
                const SizedBox(width: 4),
              ],
              Text(
                nombre,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: seleccionado ? Colors.black : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
