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
      {
        "nombre": "TUETANOS AL GRILL",
        "imagen": "assets/grid_images/tuetanos_al_grill.png",
        "precio": 120.00,
      },
      {
        "nombre": "NACHOS PPARRILLA VILLA",
        "icono": Icons.local_pizza,
        "precio": 100.00,
      },
      {
        "nombre": "ORDEN DE CHISTORRA",
        "icono": Icons.fastfood,
        "precio": 150.00,
      },
      {
        "nombre": "JALAPEÑOS RELLENOS",
        "icono": Icons.fastfood,
        "precio": 80.00,
      },
      {
        "nombre": "ORDEN DE QUESO ASADO",
        "icono": Icons.fastfood,
        "precio": 90.00,
      },
      {
        "nombre": "ORDEN DE GUACAMOLE",
        "icono": Icons.fastfood,
        "precio": 110.00,
      },
      {
        "nombre": "PAPAS A LA FRANCESA GRATINADAS",
        "icono": Icons.fastfood,
        "precio": 70.00,
      },
      {
        "nombre": "ORDEN DE NOPALES ASADOS",
        "icono": Icons.fastfood,
        "precio": 60.00,
      },
      {
        "nombre": "ORDEN DE FRIJOLES CHARROS",
        "icono": Icons.fastfood,
        "precio": 50.00,
      },
      {
        "nombre": "ORDEN DE TORTILLAS DE HARINA",
        "icono": Icons.fastfood,
        "precio": 40.00,
      },
    ],
    "Ensaladas": [
      {
        "nombre": "ENSALADA CON ARRACHERA",
        "icono": Icons.emoji_food_beverage,
        "precio": 120.00,
      },
      {
        "nombre": "ENSALADA CON POLLO",
        "icono": Icons.emoji_food_beverage,
        "precio": 100.00,
      },
      {
        "nombre": "ENSALADA CON SIRLOIN",
        "icono": Icons.emoji_food_beverage,
        "precio": 150.00,
      },
      {
        "nombre": "ENSALADA CON ATUN",
        "icono": Icons.emoji_food_beverage,
        "precio": 130.00,
      },
      {
        "nombre": "ENSALADA VILLA",
        "icono": Icons.emoji_food_beverage,
        "precio": 140.00,
      },
    ],
    "Sopas": [
      {
        "nombre": "PASTA ALFREDO CON POLLO",
        "icono": Icons.ramen_dining,
        "precio": 160.00,
      },
      {"nombre": "SOPA AZTECA", "icono": Icons.ramen_dining, "precio": 90.00},
      {"nombre": "PASTA MIXTA", "icono": Icons.ramen_dining, "precio": 110.00},
      {
        "nombre": "CONSOME DE POLLO",
        "icono": Icons.ramen_dining,
        "precio": 80.00,
      },
    ],
    "Quesos": [
      {"nombre": "NATURAL", "icono": Icons.fastfood, "precio": 100.00},
      {
        "nombre": "CON CHAMPIÑONES ASADOS",
        "icono": Icons.fastfood,
        "precio": 120.00,
      },
      {"nombre": "CON CHISTORRA", "icono": Icons.fastfood, "precio": 150.00},
      {"nombre": "CON LONGANIZA", "icono": Icons.fastfood, "precio": 160.00},
      {"nombre": "CON SIRLOIN", "icono": Icons.fastfood, "precio": 170.00},
      {"nombre": "CON ARRACHERA", "icono": Icons.fastfood, "precio": 180.00},
    ],
    "Papas": [
      {"nombre": "PAPA CON TOCINO", "icono": Icons.fastfood, "precio": 100.00},
      {
        "nombre": "PAPA CON CHAMPIÑONES",
        "icono": Icons.fastfood,
        "precio": 120.00,
      },
      {
        "nombre": "PAPA CON CHISTORRA",
        "icono": Icons.fastfood,
        "precio": 150.00,
      },
      {
        "nombre": "PAPA CON LONGANIZA",
        "icono": Icons.fastfood,
        "precio": 160.00,
      },
      {
        "nombre": "PAPA CON CARNE ENCHILADA",
        "icono": Icons.fastfood,
        "precio": 170.00,
      },
      {"nombre": "PAPA CON SIRLOIN", "icono": Icons.fastfood, "precio": 180.00},
      {
        "nombre": "PAPA CON ARRACHERA",
        "icono": Icons.fastfood,
        "precio": 190.00,
      },
    ],
    "Todos": [
      {
        "nombre": "CHICHARRON DE RIB-EYE",
        "icono": Icons.fastfood,
        "precio": 200.00,
      },
      {
        "nombre": "CHAMORRO EN ADOBO",
        "icono": Icons.local_drink,
        "precio": 210.00,
      },
      {
        "nombre": "ENCHILADAS SUIZAS",
        "icono": Icons.icecream,
        "precio": 220.00,
      },
      {"nombre": "ORDEN DE SIRLOIN", "icono": Icons.cake, "precio": 230.00},
      {"nombre": "PECHUGA AL GRILL", "icono": Icons.fastfood, "precio": 240.00},
      {
        "nombre": "ORDEN DE CARNE DE ENCHILADA",
        "icono": Icons.fastfood,
        "precio": 250.00,
      },
      {
        "nombre": "COSTILLAS A LA BBQ",
        "icono": Icons.fastfood,
        "precio": 260.00,
      },
      {
        "nombre": "ALITAS AL CARBON O FRITAS",
        "icono": Icons.fastfood,
        "precio": 270.00,
      },
      {"nombre": "BURRITO", "icono": Icons.fastfood, "precio": 280.00},
      {"nombre": "ALAMBRE", "icono": Icons.fastfood, "precio": 290.00},
      {"nombre": "ORDEN DE NUGGETS", "icono": Icons.fastfood, "precio": 300.00},
      {
        "nombre": "HAMBURGUESA DOBLE",
        "icono": Icons.fastfood,
        "precio": 310.00,
      },
      {
        "nombre": "HAMBURGUESA SENCILLA",
        "icono": Icons.fastfood,
        "precio": 320.00,
      },
      {
        "nombre": "HAMBURGUESA LA GUERRILLERA",
        "icono": Icons.fastfood,
        "precio": 330.00,
      },
      {"nombre": "EXTRA DE PIÑA", "icono": Icons.fastfood, "precio": 340.00},
      {
        "nombre": "EXTRA DE 3 QUESOS",
        "icono": Icons.fastfood,
        "precio": 350.00,
      },
      {
        "nombre": "EXTRA DE GUACAMOLE",
        "icono": Icons.fastfood,
        "precio": 360.00,
      },
      {"nombre": "EXTRA DE TOCINO", "icono": Icons.fastfood, "precio": 370.00},
    ],
    "Costillas": [
      {"nombre": "COSTILLA 1/4 KG", "icono": Icons.fastfood, "precio": 380.00},
      {"nombre": "COSTILLA 1/2 KG", "icono": Icons.fastfood, "precio": 390.00},
      {"nombre": "COSTILLA 1KG", "icono": Icons.fastfood, "precio": 400.00},
    ],
    "Molcajetes": [
      {
        "nombre": "MOLCAJETE TRADICIONAL (2 PERSONAS)",
        "icono": Icons.fastfood,
        "precio": 500.00,
      },
      {
        "nombre": "MOLCAJETE TRADICIONAL (4 PERSONAS)",
        "icono": Icons.fastfood,
        "precio": 1000.00,
      },
      {
        "nombre": "MOLCAJETE PREMIUM",
        "icono": Icons.fastfood,
        "precio": 1500.00,
      },
    ],
    "Cortes": [
      {"nombre": "ARRACHERA", "icono": Icons.fastfood, "precio": 400.00},
      {"nombre": "T-BONE", "icono": Icons.fastfood, "precio": 500.00},
      {"nombre": "RIB EYE", "icono": Icons.fastfood, "precio": 600.00},
      {"nombre": "TOMAHAWK", "icono": Icons.fastfood, "precio": 700.00},
    ],
    "Tacos": [
      {
        "nombre": "TACO DE ARRACHERA",
        "icono": Icons.fastfood,
        "precio": 400.00,
      },
      {"nombre": "TACO DE SIRLOIN", "icono": Icons.fastfood, "precio": 500.00},
      {"nombre": "TACO DE POLLO", "icono": Icons.fastfood, "precio": 300.00},
      {
        "nombre": "TACO DE CHISTORRA",
        "icono": Icons.fastfood,
        "precio": 300.00,
      },
      {
        "nombre": "TACO DE LONGANIZA",
        "icono": Icons.fastfood,
        "precio": 300.00,
      },
      {
        "nombre": "TACO DE CARNE ENCHILADA",
        "icono": Icons.fastfood,
        "precio": 300.00,
      },
    ],
    "Volcanes": [
      {
        "nombre": "VOLCAN DE ARRACHERA",
        "icono": Icons.fastfood,
        "precio": 400.00,
      },
      {
        "nombre": "VOLCAN DE SIRLOIN",
        "icono": Icons.fastfood,
        "precio": 500.00,
      },
      {"nombre": "VOLCAN DE POLLO", "icono": Icons.fastfood, "precio": 300.00},
      {
        "nombre": "VOLCAN DE CHISTORRA",
        "icono": Icons.fastfood,
        "precio": 300.00,
      },
      {
        "nombre": "VOLCAN DE LONGANIZA",
        "icono": Icons.fastfood,
        "precio": 300.00,
      },
      {
        "nombre": "VOLCAN DE CARNE ENCHILADA",
        "icono": Icons.fastfood,
        "precio": 300.00,
      },
    ],
    "Bebidas": [
      {"nombre": "Coca-Cola", "icono": Icons.local_drink, "precio": 30.00},
      {"nombre": "Agua", "icono": Icons.water_drop, "precio": 20.00},
      {"nombre": "Jugo", "icono": Icons.local_cafe, "precio": 25.00},
    ],
    "Postres": [
      {
        "nombre": "POSTRE ESPECIAL DE LA CASA",
        "icono": Icons.icecream,
        "precio": 100.00,
      },
      {"nombre": "BOLA DE HELADO", "icono": Icons.cake, "precio": 50.00},
      {"nombre": "LAS ADELITAS", "icono": Icons.cookie, "precio": 75.00},
      {"nombre": "PANCHO CREPA", "icono": Icons.cookie, "precio": 80.00},
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
                                      Image.asset(
                                        producto['imagen'],
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        producto['nombre'],
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "\$${producto['precio']}",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
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
