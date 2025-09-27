import 'package:flutter/material.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  String categoriaSeleccionada = "Alimentos"; // valor inicial

  // Productos: solo nombres, para botones sin imagen
  final Map<String, List<Map<String, dynamic>>> productos = {
    "Entradas": [
      {"nombre": "TUETANOS AL GRILL", "icono": Icons.lunch_dining},
      {"nombre": "NACHOS PPARRILLA VILLA", "icono": Icons.local_pizza},
      {"nombre": "ORDEN DE CHISTORRA", "icono": Icons.fastfood},
      {"nombre": "JALAPEÑOS RELLENOS", "icono": Icons.fastfood},
      {"nombre": "ORDEN DE QUESO ASADO", "icono": Icons.fastfood},
      {"nombre": "ORDEN DE GUACAMOLE", "icono": Icons.fastfood},
      {"nombre": "PAPAS A LA FRANCESA GRATINADAS", "icono": Icons.fastfood},
      {"nombre": "ORDEN DE NOPALES ASADOS", "icono": Icons.fastfood},
      {"nombre": "ORDEN DE FRIJOLES CHARROS", "icono": Icons.fastfood},
      {"nombre": "ORDEN DE TORTILLAS DE HARINA", "icono": Icons.fastfood},
    ],
    "Ensaladas": [
      {"nombre": "ENSALADA CON ARRACHERA", "icono": Icons.emoji_food_beverage},
      {"nombre": "ENSALADA CON POLLO", "icono": Icons.emoji_food_beverage},
      {"nombre": "ENSALADA CON SIRLOIN", "icono": Icons.emoji_food_beverage},
      {"nombre": "ENSALADA CON ATUN", "icono": Icons.emoji_food_beverage},
      {"nombre": "ENSALADA VILLA", "icono": Icons.emoji_food_beverage},
    ],
    "Sopas": [
      {"nombre": "PASTA ALFREDO CON POLLO", "icono": Icons.ramen_dining},
      {"nombre": "SOPA AZTECA", "icono": Icons.ramen_dining},
      {"nombre": "PASTA MIXTA", "icono": Icons.ramen_dining},
      {"nombre": "CONSOME DE POLLO", "icono": Icons.ramen_dining},
    ],
    "Quesos": [
      {"nombre": "NATURAL", "icono": Icons.fastfood},
      {"nombre": "CON CHAMPIÑONES ASADOS", "icono": Icons.fastfood},
      {"nombre": "CON CHISTORRA", "icono": Icons.fastfood},
      {"nombre": "CON LONGANIZA", "icono": Icons.fastfood},
      {"nombre": "CON SIRLOIN", "icono": Icons.fastfood},
      {"nombre": "CON ARRACHERA", "icono": Icons.fastfood},
    ],
    "Papas": [
      {"nombre": "PAPA CON TOCINO", "icono": Icons.fastfood},
      {"nombre": "PAPA CON CHAMPIÑONES", "icono": Icons.fastfood},
      {"nombre": "PAPA CON CHISTORRA", "icono": Icons.fastfood},
      {"nombre": "PAPA CON LONGANIZA", "icono": Icons.fastfood},
      {"nombre": "PAPA CON CARNE ENCHILADA", "icono": Icons.fastfood},
      {"nombre": "PAPA CON SIRLOIN", "icono": Icons.fastfood},
      {"nombre": "PAPA CON ARRACHERA", "icono": Icons.fastfood},
    ],
    "Todos": [
      {"nombre": "CHICHARRON DE RIB-EYE", "icono": Icons.fastfood},
      {"nombre": "CHAMORRO EN ADOBO", "icono": Icons.local_drink},
      {"nombre": "ENCHILADAS SUIZAS", "icono": Icons.icecream},
      {"nombre": "ORDEN DE SIRLOIN", "icono": Icons.cake},
      {"nombre": "PECHUGA AL GRILL", "icono": Icons.fastfood},
      {"nombre": "ORDEN DE CARNE DE ENCHILADA", "icono": Icons.fastfood},
      {"nombre": "COSTILLAS A LA BBQ", "icono": Icons.fastfood},
      {"nombre": "ALITAS AL CARBON O FRITAS", "icono": Icons.fastfood},
      {"nombre": "BURRITO", "icono": Icons.fastfood},
      {"nombre": "ALAMBRE", "icono": Icons.fastfood},
      {"nombre": "ORDEN DE NUGGETS", "icono": Icons.fastfood},
      {"nombre": "HAMBURGUESA DOBLE", "icono": Icons.fastfood},
      {"nombre": "HAMBURGUESA SENCILLA", "icono": Icons.fastfood},
      {"nombre": "HAMBURGUESA LA GUERRILLERA", "icono": Icons.fastfood},
      {"nombre": "EXTRA DE PIÑA", "icono": Icons.fastfood},
      {"nombre": "EXTRA DE 3 QUESOS", "icono": Icons.fastfood},
      {"nombre": "EXTRA DE GUACAMOLE", "icono": Icons.fastfood},
      {"nombre": "EXTRA DE TOCINO", "icono": Icons.fastfood},
    ],
    "Costillas": [
      {"nombre": "COSTILLA 1/4 KG", "icono": Icons.fastfood},
      {"nombre": "COSTILLA 1/2 KG", "icono": Icons.fastfood},
      {"nombre": "COSTILLA 1KG", "icono": Icons.fastfood},
    ],
    "Molcajetes": [
      {"nombre": "MOLCAJETE TRADICIONAL (2 PERSONAS)", "icono": Icons.fastfood},
      {"nombre": "MOLCAJETE TRADICIONAL (4 PERSONAS)", "icono": Icons.fastfood},
      {"nombre": "MOLCAJETE PREMIUM", "icono": Icons.fastfood},
    ],
    "Cortes": [
      {"nombre": "ARRACHERA", "icono": Icons.fastfood},
      {"nombre": "T-BONE", "icono": Icons.fastfood},
      {"nombre": "RIB EYE", "icono": Icons.fastfood},
      {"nombre": "TOMAHAWK", "icono": Icons.fastfood},
    ],
    "Tacos": [
      {"nombre": "TACO DE ARRACHERA", "icono": Icons.fastfood},
      {"nombre": "TACO DE SIRLOIN", "icono": Icons.fastfood},
      {"nombre": "TACO DE POLLO", "icono": Icons.fastfood},
      {"nombre": "TACO DE CHISTORRA", "icono": Icons.fastfood},
      {"nombre": "TACO DE LONGANIZA", "icono": Icons.fastfood},
      {"nombre": "TACO DE CARNE ENCHILADA", "icono": Icons.fastfood},
    ],
    "Volcanes": [
      {"nombre": "VOLCAN DE ARRACHERA", "icono": Icons.fastfood},
      {"nombre": "VOLCAN DE SIRLOIN", "icono": Icons.fastfood},
      {"nombre": "VOLCAN DE POLLO", "icono": Icons.fastfood},
      {"nombre": "VOLCAN DE CHISTORRA", "icono": Icons.fastfood},
      {"nombre": "VOLCAN DE LONGANIZA", "icono": Icons.fastfood},
      {"nombre": "VOLCAN DE CARNE ENCHILADA", "icono": Icons.fastfood},
    ],
    "Bebidas": [
      {"nombre": "Coca-Cola", "icono": Icons.local_drink},
      {"nombre": "Agua", "icono": Icons.water_drop},
      {"nombre": "Jugo", "icono": Icons.local_cafe},
    ],
    "Postres": [
      {"nombre": "POSTRE ESPECIAL DE LA CASA", "icono": Icons.icecream},
      {"nombre": "BOLA DE HELADO", "icono": Icons.cake},
      {"nombre": "LAS ADELITAS", "icono": Icons.cookie},
      {"nombre": "PANCHO CREPA", "icono": Icons.cookie},
    ],
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
                        Container(
                          height: 350, // Altura fija más pequeña
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
                                  const SizedBox(width: 80),
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
                                  const SizedBox(width: 80),
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

                        const SizedBox(height: 5),

                        // ===== BOTONES POS =====
                        Container(
                          height: 300,
                          padding: EdgeInsets.zero,
                          margin: EdgeInsets.zero,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: GridView.count(
                              crossAxisCount: 4,
                              mainAxisSpacing: 9,
                              crossAxisSpacing: 8,
                              childAspectRatio: 3,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                _botonAccion(Icons.local_offer, "NOTA", () {}),
                                _botonAccion(Icons.cancel, "CANCELAR", () {}),
                                _botonAccion(
                                  Icons.access_time,
                                  "TIEMPOS",
                                  () {},
                                ),
                                _botonAccion(Icons.delete, "", () {}),

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

                                const SizedBox.shrink(),
                                _botonAccion(Icons.add, "+", () {}),
                                _botonAccion(Icons.remove, "-", () {}),
                                _botonNumero("0"),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  // ========== LADO DERECHO ==========
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        // ===== BOTONES DE CATEGORIAS =====
                        Container(
                          height: 70,
                          color: Colors.grey[300],
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _categoriaBoton('Entradas'),
                              _categoriaBoton('Ensaladas'),
                              _categoriaBoton('Sopas'),
                              _categoriaBoton('Quesos'),
                              _categoriaBoton('Papas'),
                              _categoriaBoton('Todos'),
                              _categoriaBoton('Costillas'),
                              _categoriaBoton('Molcajetes'),
                              _categoriaBoton('Cortes'),
                              _categoriaBoton('Tacos'),
                              _categoriaBoton('Volcanes'),
                              _categoriaBoton('Comida'),
                              _categoriaBoton('Postres'),
                              _categoriaBoton('Bebidas'),
                              _categoriaBoton('Buscar..', icono: Icons.search),
                            ],
                          ),
                        ),

                        const SizedBox(height: 5),

                        // ===== GRID DE PRODUCTOS =====
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
                                    childAspectRatio: 1.0, // Cambié de 2 a 1.0
                                    mainAxisSpacing: 10,
                                    crossAxisSpacing: 10,
                                  ),
                              itemBuilder: (context, index) {
                                final producto =
                                    productos[categoriaSeleccionada]![index];
                                return ElevatedButton(
                                  onPressed: () {
                                    print(
                                      "Presionaste ${producto['nombre']}",
                                    ); // Cambié aquí
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
                                    padding: WidgetStateProperty.all(
                                      // Agregué padding
                                      const EdgeInsets.all(8),
                                    ),
                                  ),
                                  child: Column(
                                    // Cambié de Text a Column
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        producto['icono'],
                                        size: 40,
                                        color: Colors.orange,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        producto['nombre'],
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
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

  // ===================== MÉTODOS HELPER =====================

  ButtonStyle _botonEstilo({double minWidth = 90, double minHeight = 30}) {
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

  Widget _botonAccion(IconData icono, String texto, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: _botonEstilo(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icono, size: 20),
          if (texto.isNotEmpty)
            FittedBox(
              child: Text(
                texto,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
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
      padding: const EdgeInsets.symmetric(horizontal: 0.1, vertical: 15),
      child: GestureDetector(
        onTap: () {
          setState(() {
            categoriaSeleccionada = nombre;
          });
        },
        child: Container(
          width: 89,
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

  Widget _botonNumero(String texto) {
    return ElevatedButton(
      onPressed: () {},
      style: _botonEstilo(),
      child: Text(
        texto,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
