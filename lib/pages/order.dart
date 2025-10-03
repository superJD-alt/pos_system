import 'package:flutter/material.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  String categoriaSeleccionada = "Alimentos"; // valor inicial

  int cantidadBuffer = 0; //contador para botones

  int totalItems = 0; //contador de total de items
  double totalGeneral = 0.0; //contador de totalGeneral

  Map<String, dynamic>?
  productoSeleccionado; //producto seleccionado actualmente en la tabla de orden

  List<Map<String, dynamic>> ordenes =
      []; //lista para productos en tabla de ordenes

  // Productos: solo nombres, para botones sin imagen
  final Map<String, dynamic> productos = {
    "Entradas": <Map<String, dynamic>>[
      {
        "nombre": "TUETANOS AL GRILL",
        "imagen": "assets/grid_images/tuetanosAlGrill.jpg",
        "precio": 120.00,
      },
      {
        "nombre": "NACHOS PPARRILLA VILLA",
        "imagen": "assets/grid_images/nachosConQueso.jpg",
        "precio": 100.00,
      },
      {
        "nombre": "ORDEN DE CHISTORRA",
        "imagen": "assets/grid_images/ordenChistorra.jpeg",
        "precio": 150.00,
      },
      {
        "nombre": "JALAPEÑOS RELLENOS",
        "imagen": "assets/grid_images/jalapenosRellenos.jpeg",
        "precio": 80.00,
      },
      {
        "nombre": "ORDEN DE QUESO ASADO",
        "imagen": "assets/grid_images/quesoAsado.jpeg",
        "precio": 90.00,
      },
      {
        "nombre": "ORDEN DE GUACAMOLE",
        "imagen": "assets/grid_images/guacamole.jpeg",
        "precio": 110.00,
      },
      {
        "nombre": "PAPAS A LA FRANCESA GRATINADAS",
        "imagen": "assets/grid_images/papasFrancesa.jpg",
        "precio": 70.00,
      },
      {
        "nombre": "ORDEN DE NOPALES ASADOS",
        "imagen": "assets/grid_images/nopalesAsados.jpg",
        "precio": 60.00,
      },
      {
        "nombre": "ORDEN DE FRIJOLES CHARROS",
        "imagen": "assets/grid_images/frijolesCharros.jpg",
        "precio": 50.00,
      },
      {
        "nombre": "ORDEN DE TORTILLAS DE HARINA",
        "imagen": "assets/grid_images/tortillasHarina.jpg",
        "precio": 40.00,
      },
    ],
    "Ensaladas": <Map<String, dynamic>>[
      {
        "nombre": "ENSALADA CON ARRACHERA",
        "imagen": "assets/grid_images/ensaladaArracherra.jpg",
        "precio": 120.00,
      },
      {
        "nombre": "ENSALADA CON POLLO",
        "imagen": "assets/grid_images/ensaladaPollo.jpeg",
        "precio": 100.00,
      },
      {
        "nombre": "ENSALADA CON SIRLOIN",
        "imagen": "assets/grid_images/ensaladaSirloin.jpeg",
        "precio": 150.00,
      },
      {
        "nombre": "ENSALADA CON ATUN",
        "imagen": "assets/grid_images/ensaladaAtun.jpeg",
        "precio": 130.00,
      },
      {
        "nombre": "ENSALADA VILLA",
        "imagen": "assets/grid_images/ensaladaVilla.jpg",
        "precio": 140.00,
      },
    ],
    "Sopas": <Map<String, dynamic>>[
      {
        "nombre": "PASTA ALFREDO CON POLLO",
        "imagen": "assets/grid_images/pastaAlfredo.jpg",
        "precio": 160.00,
      },
      {
        "nombre": "SOPA AZTECA",
        "imagen": "assets/grid_images/sopaAzteca.jpg",
        "precio": 90.00,
      },
      {
        "nombre": "PASTA MIXTA",
        "imagen": "assets/grid_images/pastaMixta.jpg",
        "precio": 110.00,
      },
      {
        "nombre": "CONSOME DE POLLO",
        "imagen": "assets/grid_images/consomePollo.jpg",
        "precio": 80.00,
      },
    ],
    "Quesos": <Map<String, dynamic>>[
      {
        "nombre": "NATURAL",
        "imagen": "assets/grid_images/quesoNatural.jpeg",
        "precio": 100.00,
      },
      {
        "nombre": "CON CHAMPIÑONES ASADOS",
        "imagen": "assets/grid_images/quesoChampinon.jpg",
        "precio": 120.00,
      },
      {
        "nombre": "CON CHISTORRA",
        "imagen": "assets/grid_images/quesoChistoraa.jpg",
        "precio": 150.00,
      },
      {
        "nombre": "CON LONGANIZA",
        "imagen": "assets/grid_images/quesoLonganiza.jpeg",
        "precio": 160.00,
      },
      {
        "nombre": "CON SIRLOIN",
        "imagen": "assets/grid_images/quesoSirloin.jpeg",
        "precio": 170.00,
      },
      {
        "nombre": "CON ARRACHERA",
        "imagen": "assets/grid_images/quesoArracherra.jpg",
        "precio": 180.00,
      },
    ],
    "Papas": <Map<String, dynamic>>[
      {
        "nombre": "PAPA CON TOCINO",
        "imagen": "assets/grid_images/papaTocino.jpg",
        "precio": 100.00,
      },
      {
        "nombre": "PAPA CON CHAMPIÑONES",
        "imagen": "assets/grid_images/papaChampinon.jpg",
        "precio": 120.00,
      },
      {
        "nombre": "PAPA CON CHISTORRA",
        "imagen": "assets/grid_images/papasChistorra.jpg",
        "precio": 150.00,
      },
      {
        "nombre": "PAPA CON LONGANIZA",
        "imagen": "assets/grid_images/papasLonganiza.jpg",
        "precio": 160.00,
      },
      {
        "nombre": "PAPA CON CARNE ENCHILADA",
        "imagen": "assets/grid_images/papaCarne.jpg",
        "precio": 170.00,
      },
      {
        "nombre": "PAPA CON SIRLOIN",
        "imagen": "assets/grid_images/papaSirloin.jpeg",
        "precio": 180.00,
      },
      {
        "nombre": "PAPA CON ARRACHERA",
        "imagen": "assets/grid_images/papaArrachera.jpeg",
        "precio": 190.00,
      },
    ],
    "Todos": <Map<String, dynamic>>[
      {
        "nombre": "CHICHARRON DE RIB-EYE",
        "imagen": "assets/grid_images/chicharronRibEye.jpeg",
        "precio": 200.00,
      },
      {
        "nombre": "CHAMORRO EN ADOBO",
        "imagen": "assets/grid_images/chamorroAdobo.jpeg",
        "precio": 210.00,
      },
      {
        "nombre": "ENCHILADAS SUIZAS",
        "imagen": "assets/grid_images/enchiladasSuizas.jpg",
        "precio": 220.00,
      },
      {
        "nombre": "ORDEN DE SIRLOIN",
        "imagen": "assets/grid_images/ordenSirloin.jpeg",
        "precio": 230.00,
      },
      {
        "nombre": "PECHUGA AL GRILL",
        "imagen": "assets/grid_images/pechugaGrill.jpeg",
        "precio": 240.00,
      },
      {
        "nombre": "ORDEN DE CARNE DE ENCHILADA",
        "imagen": "assets/grid_images/ordenEnchilada.jpg",
        "precio": 250.00,
      },
      {
        "nombre": "COSTILLAS A LA BBQ",
        "imagen": "assets/grid_images/costillasBBQ.jpg",
        "precio": 260.00,
      },
      {
        "nombre": "ALITAS AL CARBON O FRITAS",
        "imagen": "assets/grid_images/alitasFritas.jpeg",
        "precio": 270.00,
      },
      {
        "nombre": "BURRITO",
        "imagen": "assets/grid_images/burrito.jpeg",
        "precio": 280.00,
      },
      {
        "nombre": "ALAMBRE",
        "imagen": "assets/grid_images/alambre.jpg",
        "precio": 290.00,
      },
      {
        "nombre": "ORDEN DE NUGGETS",
        "imagen": "assets/grid_images/nuggets.jpeg",
        "precio": 300.00,
      },
      {
        "nombre": "HAMBURGUESA DOBLE",
        "imagen": "assets/grid_images/hamburguesaDoble.jpg",
        "precio": 310.00,
      },
      {
        "nombre": "HAMBURGUESA SENCILLA",
        "imagen": "assets/grid_images/hamburguesaSencilla.jpeg",
        "precio": 320.00,
      },
      {
        "nombre": "HAMBURGUESA LA GUERRILLERA",
        "imagen": "assets/grid_images/hamburguesaGuerrillera.jpeg",
        "precio": 330.00,
      },
      {
        "nombre": "EXTRA DE PIÑA",
        "imagen": "assets/grid_images/extraPina.jpeg",
        "precio": 340.00,
      },
      {
        "nombre": "EXTRA DE 3 QUESOS",
        "imagen": "assets/grid_images/extraQueso.jpeg",
        "precio": 350.00,
      },
      {
        "nombre": "EXTRA DE GUACAMOLE",
        "imagen": "assets/grid_images/extraGuacamole.jpeg",
        "precio": 360.00,
      },
      {
        "nombre": "EXTRA DE TOCINO",
        "imagen": "assets/grid_images/extraTocino.jpg",
        "precio": 370.00,
      },
    ],
    "Costillas": <Map<String, dynamic>>[
      {
        "nombre": "COSTILLA 1/4 KG",
        "imagen": "assets/grid_images/costillas.jpeg",
        "precio": 380.00,
      },
      {
        "nombre": "COSTILLA 1/2 KG",
        "imagen": "assets/grid_images/costillas.jpeg",
        "precio": 390.00,
      },
      {
        "nombre": "COSTILLA 1KG",
        "imagen": "assets/grid_images/costillas.jpeg",
        "precio": 400.00,
      },
    ],
    "Molcajetes": <Map<String, dynamic>>[
      {
        "nombre": "MOLCAJETE TRADICIONAL (2 PERSONAS)",
        "imagen": "assets/grid_images/molcajete.jpg",
        "precio": 500.00,
      },
      {
        "nombre": "MOLCAJETE TRADICIONAL (4 PERSONAS)",
        "imagen": "assets/grid_images/molcajete.jpg",
        "precio": 1000.00,
      },
      {
        "nombre": "MOLCAJETE PREMIUM",
        "imagen": "assets/grid_images/molcajetePremium.jpg",
        "precio": 1500.00,
      },
    ],
    "Cortes": <Map<String, dynamic>>[
      {
        "nombre": "ARRACHERA",
        "imagen": "assets/grid_images/arracheraCorte.jpeg",
        "precio": 400.00,
      },
      {
        "nombre": "T-BONE",
        "imagen": "assets/grid_images/tBoneCorte.jpg",
        "precio": 500.00,
      },
      {
        "nombre": "RIB EYE",
        "imagen": "assets/grid_images/ribEyeCorte.jpg",
        "precio": 600.00,
      },
      {
        "nombre": "TOMAHAWK",
        "imagen": "assets/grid_images/tomahawkCorte.jpg",
        "precio": 700.00,
      },
    ],
    "Tacos": <Map<String, dynamic>>[
      {
        "nombre": "TACO DE ARRACHERA",
        "imagen": "assets/grid_images/tacoArrachera.jpg",
        "precio": 400.00,
      },
      {
        "nombre": "TACO DE SIRLOIN",
        "imagen": "assets/grid_images/tacoSirloin.jpg",
        "precio": 500.00,
      },
      {
        "nombre": "TACO DE POLLO",
        "imagen": "assets/grid_images/tacoPollo.jpeg",
        "precio": 300.00,
      },
      {
        "nombre": "TACO DE CHISTORRA",
        "imagen": "assets/grid_images/tacoChistorra.jpeg",
        "precio": 300.00,
      },
      {
        "nombre": "TACO DE LONGANIZA",
        "imagen": "assets/grid_images/tacoLonganiza.jpeg",
        "precio": 300.00,
      },
      {
        "nombre": "TACO DE CARNE ENCHILADA",
        "imagen": "assets/grid_images/tacoEnchilada.jpg",
        "precio": 300.00,
      },
    ],
    "Volcanes": <Map<String, dynamic>>[
      {
        "nombre": "VOLCAN DE ARRACHERA",
        "imagen": "assets/grid_images/volcanArrachera.jpeg",
        "precio": 400.00,
      },
      {
        "nombre": "VOLCAN DE SIRLOIN",
        "imagen": "assets/grid_images/volcanSirloin.jpeg",
        "precio": 500.00,
      },
      {
        "nombre": "VOLCAN DE POLLO",
        "imagen": "assets/grid_images/volcanPollo.jpg",
        "precio": 300.00,
      },
      {
        "nombre": "VOLCAN DE CHISTORRA",
        "imagen": "assets/grid_images/volcanChistorra.jpeg",
        "precio": 300.00,
      },
      {
        "nombre": "VOLCAN DE LONGANIZA",
        "imagen": "assets/grid_images/volcanLonganiza.jpeg",
        "precio": 300.00,
      },
      {
        "nombre": "VOLCAN DE CARNE ENCHILADA",
        "imagen": "assets/grid_images/volcanEnchilada.jpeg",
        "precio": 300.00,
      },
    ],
    "Bebidas": {
      "Sin Alcohol": <Map<String, dynamic>>[
        {
          "nombre": "AGUA FRESCA CON REFIL",
          "imagen": "assets/grid_images/aguaFresca.jpeg",
          "precio": 35.00,
        },
        {
          "nombre": "PIÑADA",
          "imagen": "assets/grid_images/pinada.jpeg",
          "precio": 90.00,
        },
        {
          "nombre": "NARANJADA",
          "imagen": "assets/grid_images/naranjada.jpeg",
          "precio": 25.00,
        },
        {
          "nombre": "LIMONADA",
          "imagen": "assets/grid_images/limonada.jpeg",
          "precio": 25.00,
        },
        {
          "nombre": "JUGO VALLE MANGO",
          "imagen": "assets/grid_images/jugoMango.jpeg",
          "precio": 25.00,
        },
        {
          "nombre": "AGUA MINERAL S.PELLEGRINO",
          "imagen": "assets/grid_images/aguaMineral.jpeg",
          "precio": 25.00,
        },
        {
          "nombre": "AGUA MINERAL DE TAXCO",
          "imagen": "assets/grid_images/aguaTaxco.jpeg",
          "precio": 25.00,
        },
        {
          "nombre": "BOTELLA DE AGUA NATURAL",
          "imagen": "assets/grid_images/agua.jpg",
          "precio": 25.00,
        },
        {
          "nombre": "TAZA DE CAFÉ",
          "imagen": "assets/grid_images/tazaCafe.jpg",
          "precio": 25.00,
        },
      ],
      "Refrescos": <Map<String, dynamic>>[
        {
          "nombre": "COCA-COLA",
          "imagen": "assets/grid_images/cocaCola.jpeg",
          "precio": 25.00,
        },
        {
          "nombre": "SIDRAL MUNDET",
          "imagen": "assets/grid_images/sidral.png",
          "precio": 25.00,
        },
        {
          "nombre": "YOLI",
          "imagen": "assets/grid_images/yoli.jpeg",
          "precio": 25.00,
        },
        {
          "nombre": "FRESCA",
          "imagen": "assets/grid_images/fresca.jpeg",
          "precio": 25.00,
        },
        {
          "nombre": "FANTA",
          "imagen": "assets/grid_images/fanta.png",
          "precio": 25.00,
        },
        {
          "nombre": "COCA-COLA ZERO",
          "imagen": "assets/grid_images/cocaZero.png",
          "precio": 25.00,
        },
      ],
      "Cocteles": <Map<String, dynamic>>[
        {
          "nombre": "CLERICOT COPA",
          "imagen": "assets/grid_images/clericotCopa.png",
          "precio": 80.00,
        },
        {
          "nombre": "CLERICOT JARRA",
          "imagen": "assets/grid_images/clericotJarra.jpeg",
          "precio": 300.00,
        },
        {
          "nombre": "MOJITO",
          "imagen": "assets/grid_images/mojito.jpeg",
          "precio": 85.00,
        },
        {
          "nombre": "BERTA",
          "imagen": "assets/grid_images/berta.jpg",
          "precio": 85.00,
        },
        {
          "nombre": "SUEÑO DE UVA",
          "imagen": "assets/grid_images/suenoUva.jpeg",
          "precio": 85.00,
        },
        {
          "nombre": "ESCARLATA FIZZ",
          "imagen": "assets/grid_images/escarlataFizz.jpeg",
          "precio": 95.00,
        },
        {
          "nombre": "TINTO DE VERANO",
          "imagen": "assets/grid_images/tintoVerano.jpeg",
          "precio": 95.00,
        },
        {
          "nombre": "CARAJILLO",
          "imagen": "assets/grid_images/carajillo.jpeg",
          "precio": 115.00,
        },
        {
          "nombre": "CANTARITO",
          "imagen": "assets/grid_images/cantarito.jpeg",
          "precio": 100.00,
        },
        {
          "nombre": "PIÑA COLADA",
          "imagen": "assets/grid_images/pinaColada.jpeg",
          "precio": 110.00,
        },
        {
          "nombre": "AFFOGATO",
          "imagen": "assets/grid_images/jugo.jpeg",
          "precio": 120.00,
        },
        {
          "nombre": "APEROL SPRITZ",
          "imagen": "assets/grid_images/aperolSpritz.jpeg",
          "precio": 120.00,
        },
        {
          "nombre": "BAILEYS",
          "imagen": "assets/grid_images/baileys.jpeg",
          "precio": 120.00,
        },
      ],
      "Cervezas": <Map<String, dynamic>>[
        {
          "nombre": "VICTORIA",
          "imagen": "assets/grid_images/victoria.jpeg",
          "precio": 35.00,
        },
        {
          "nombre": "CORONA",
          "imagen": "assets/grid_images/corona.jpg",
          "precio": 35.00,
        },
        {
          "nombre": "NEGRA MODELO",
          "imagen": "assets/grid_images/negraModelo.jpeg",
          "precio": 40.00,
        },
        {
          "nombre": "MODELO ESPECIAL",
          "imagen": "assets/grid_images/modeloEspecial.jpeg",
          "precio": 40.00,
        },
        {
          "nombre": "PACIFICO",
          "imagen": "assets/grid_images/pacifico.png",
          "precio": 40.00,
        },
        {
          "nombre": "ULTRA",
          "imagen": "assets/grid_images/ultra.png",
          "precio": 40.00,
        },
        {
          "nombre": "STELLA ARTOIS",
          "imagen": "assets/grid_images/stellaArtois.jpeg",
          "precio": 45.00,
        },
        {
          "nombre": "VASO CUBANO",
          "imagen": "assets/grid_images/vasoCubano.jpg",
          "precio": 15.00,
        },
        {
          "nombre": "VASO CON CLAMATO O MICHELADO",
          "imagen": "assets/grid_images/vasoClamato.jpeg",
          "precio": 20.00,
        },
      ],
      "Tequila": <Map<String, dynamic>>[
        {
          "nombre": "TEQUILA GRAN CENTENARIO REPOSADO",
          "imagen": "assets/grid_images/tequilaCentenario.jpeg",
          "precio": 85.00,
        },
        {
          "nombre": "JOSE CUERVO TRADICIONAL REPOSADO",
          "imagen": "assets/grid_images/joseCuervo.jpeg",
          "precio": 75.00,
        },
      ],
      "Whiskey": <Map<String, dynamic>>[
        {
          "nombre": "CHIVAS REGAL",
          "imagen": "assets/grid_images/chivasRegal.jpeg",
          "precio": 135.00,
        },
        {
          "nombre": "BUCHANANS",
          "imagen": "assets/grid_images/buchanans.jpeg",
          "precio": 125.00,
        },
        {
          "nombre": "ETIQUETA ROJA",
          "imagen": "assets/grid_images/etiquetaRoja.jpeg",
          "precio": 85.00,
        },
      ],
      "Brandy": <Map<String, dynamic>>[
        {
          "nombre": "TORRES 10",
          "imagen": "assets/grid_images/torres10.jpeg",
          "precio": 95.00,
        },
      ],
      "Mezcal": <Map<String, dynamic>>[
        {
          "nombre": "MEZCAL",
          "imagen": "assets/grid_images/mezcal.jpeg",
          "precio": 55.00,
        },
        {
          "nombre": "MEZCAL 400 CONEJOS",
          "imagen": "assets/grid_images/mezcalConejos.jpeg",
          "precio": 75.00,
        },
      ],
      "Vinos": <Map<String, dynamic>>[
        {
          "nombre": "BOTELLA DE VINO",
          "imagen": "assets/grid_images/botellaVino.jpeg",
          "precio": 300.00,
        },
        {
          "nombre": "COPA DE VINO TINTO O BLANCO",
          "imagen": "assets/grid_images/copaVino.jpeg",
          "precio": 75.00,
        },
      ],
    },
    "Postres": <Map<String, dynamic>>[
      {
        "nombre": "POSTRE ESPECIAL DE LA CASA",
        "imagen": "assets/grid_images/postreDeLaCasa.jpg",
        "precio": 100.00,
      },
      {
        "nombre": "BOLA DE HELADO",
        "imagen": "assets/grid_images/bolasHelado.jpg",
        "precio": 50.00,
      },
      {
        "nombre": "LAS ADELITAS",
        "imagen": "assets/grid_images/postreAdelita.png",
        "precio": 75.00,
      },
      {
        "nombre": "PANCHO CREPA",
        "imagen": "assets/grid_images/postrePancho.jpeg",
        "precio": 80.00,
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      resizeToAvoidBottomInset:
          false, //para abrir el teclado de notas sin que la UI de mueva
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
                                  DataColumn(label: Text('T')),
                                  DataColumn(label: Text('Precio')),
                                  DataColumn(label: Text('Total')),
                                ],
                                rows: ordenes.expand((item) {
                                  bool seleccionado =
                                      productoSeleccionado == item;

                                  // Fila principal del producto
                                  final mainRow = DataRow(
                                    selected: seleccionado,
                                    onSelectChanged: (val) {
                                      setState(() {
                                        productoSeleccionado = item;
                                      });
                                    },
                                    cells: [
                                      DataCell(
                                        Text(item['cantidad'].toString()),
                                      ),
                                      const DataCell(
                                        SizedBox(
                                          width: 10,
                                          child: Text(
                                            '/',
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      DataCell(Text(item['nombre'])),
                                      DataCell(
                                        SizedBox(
                                          width: 10,
                                          child: Text(
                                            item['tiempo']?.toString() ?? '1',
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      DataCell(Text("\$${item['precio']}")),
                                      DataCell(
                                        Text(
                                          "\$${(item['precio'] * item['cantidad']).toStringAsFixed(2)}",
                                        ),
                                      ),
                                    ],
                                  );

                                  // Fila extra para la nota, si existe
                                  if ((item['nota'] ?? "").isNotEmpty) {
                                    final noteRow = DataRow(
                                      cells: [
                                        const DataCell(SizedBox()), // vacío
                                        const DataCell(SizedBox()), // vacío
                                        DataCell(
                                          Text(
                                            "Nota: ${item['nota']}",
                                            style: const TextStyle(
                                              fontStyle: FontStyle.italic,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                        const DataCell(SizedBox()), // vacío
                                        const DataCell(SizedBox()), // vacío
                                      ],
                                    );
                                    return [mainRow, noteRow];
                                  } else {
                                    return [mainRow];
                                  }
                                }).toList(),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 5),

                        // ===== CONTENEDOR TOTAL =====
                        Container(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  readOnly: true,
                                  controller: TextEditingController(
                                    text: totalItems.toString(),
                                  ),
                                  decoration: const InputDecoration(
                                    labelText: 'Total de ítems',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  readOnly: true,
                                  controller: TextEditingController(
                                    text:
                                        "\$${totalGeneral.toStringAsFixed(2)}",
                                  ),
                                  decoration: const InputDecoration(
                                    labelText: 'Total general',
                                  ),
                                ),
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
                                _botonAccion(
                                  Icons.local_offer,
                                  "NOTA",
                                  _agregarNota,
                                ),
                                _botonAccion(Icons.cancel, "CANCELAR", () {}),
                                _botonAccion(
                                  Icons.access_time,
                                  "TIEMPOS",
                                  _cambiarTiempo,
                                ),
                                _botonAccion(
                                  Icons.delete,
                                  "",
                                  _eliminarProducto,
                                ),

                                _botonAccion(
                                  Icons.swap_horiz,
                                  "TRANSFERIR",
                                  () {},
                                ),
                                _botonNumero(
                                  "1",
                                  onPressed: () {
                                    if (productoSeleccionado != null) {
                                      setState(() {
                                        productoSeleccionado!['cantidad'] = 1;
                                        productoSeleccionado!['total'] =
                                            (productoSeleccionado!['cantidad']
                                                as int) *
                                            (productoSeleccionado!['precio']
                                                as double);
                                        _recalcularTotales();
                                      });
                                    }
                                  },
                                ),

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
                                _botonAccion(
                                  Icons.add,
                                  "+",
                                  _incrementarCantidad,
                                ),
                                _botonAccion(
                                  Icons.remove,
                                  "-",
                                  _disminuirCantidad,
                                ),
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
                              _categoriaBoton('Postres'),
                              _categoriaBoton('Bebidas'),
                              //_categoriaBoton('Buscar..', icono: Icons.search),
                            ],
                          ),
                        ),

                        const SizedBox(height: 5),

                        // ===== GRID DE PRODUCTOS =====
                        Expanded(
                          child: Container(
                            color: Colors.grey[300],
                            padding: const EdgeInsets.all(10),
                            child: categoriaSeleccionada == "Bebidas"
                                ? ListView(
                                    children: (productos["Bebidas"] as Map<String, List>).entries.map((
                                      entry,
                                    ) {
                                      final subCategoria = entry.key;
                                      final lista = entry.value;
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          //  Encabezado de la subcategoría
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8.0,
                                            ),
                                            child: Text(
                                              subCategoria,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),

                                          //  Grid con productos de esa subcategoría
                                          GridView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: lista.length,
                                            gridDelegate:
                                                const SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 3,
                                                  childAspectRatio: 1.0,
                                                  mainAxisSpacing: 10,
                                                  crossAxisSpacing: 10,
                                                ),
                                            itemBuilder: (context, index) {
                                              final producto = lista[index];
                                              return ElevatedButton(
                                                onPressed: () {
                                                  _agregarProducto(producto);
                                                },
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      WidgetStateProperty.all(
                                                        Colors.white,
                                                      ),
                                                  foregroundColor:
                                                      WidgetStateProperty.all(
                                                        Colors.black,
                                                      ),
                                                  shape: WidgetStateProperty.all(
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                  ),
                                                  padding:
                                                      WidgetStateProperty.all(
                                                        const EdgeInsets.all(8),
                                                      ),
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Image.asset(
                                                      producto['imagen'],
                                                      width: 100,
                                                      height: 100,
                                                      fit: BoxFit.cover,
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Text(
                                                      producto['nombre'],
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      "\$${producto['precio']}",
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.green,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  )
                                : GridView.builder(
                                    itemCount:
                                        productos[categoriaSeleccionada]
                                            ?.length ??
                                        0,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          childAspectRatio: 1.0,
                                          mainAxisSpacing: 10,
                                          crossAxisSpacing: 10,
                                        ),
                                    itemBuilder: (context, index) {
                                      final producto =
                                          productos[categoriaSeleccionada]![index];
                                      return ElevatedButton(
                                        onPressed: () {
                                          //_agregarProducto(producto);
                                          setState(() {
                                            // Buscar si ya existe en la orden
                                            int indexEnOrden = ordenes
                                                .indexWhere(
                                                  (p) =>
                                                      p['nombre'] ==
                                                      producto['nombre'],
                                                );
                                            if (indexEnOrden != -1) {
                                              // Ya existe → sumamos 1 a la cantidad
                                              ordenes[indexEnOrden]['cantidad'] =
                                                  (ordenes[indexEnOrden]['cantidad']
                                                      as int) +
                                                  1;
                                              ordenes[indexEnOrden]['total'] =
                                                  (ordenes[indexEnOrden]['cantidad']
                                                      as int) *
                                                  (ordenes[indexEnOrden]['precio']
                                                      as double);
                                              productoSeleccionado =
                                                  ordenes[indexEnOrden];
                                            } else {
                                              // Nuevo producto bien tipado
                                              Map<String, dynamic> nuevo = {
                                                "nombre": producto['nombre'],
                                                "precio": producto['precio'],
                                                "imagen": producto['imagen'],
                                                "cantidad": 1,
                                                "total": producto['precio'],
                                              };
                                              ordenes.add(nuevo);
                                              productoSeleccionado = nuevo;
                                            }

                                            // Recalcular totales
                                            totalItems = ordenes.fold(
                                              0,
                                              (sum, item) =>
                                                  sum +
                                                  (item['cantidad'] as int),
                                            );
                                            totalGeneral = ordenes.fold(
                                              0.0,
                                              (sum, item) =>
                                                  sum +
                                                  (item['total'] as double),
                                            );
                                          });
                                        },
                                        style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStateProperty.all(
                                                Colors.white,
                                              ),
                                          foregroundColor:
                                              WidgetStateProperty.all(
                                                Colors.black,
                                              ),
                                          shape: WidgetStateProperty.all(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          padding: WidgetStateProperty.all(
                                            const EdgeInsets.all(8),
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              producto['imagen'],
                                              width: 100,
                                              height: 100,
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

  Widget _botonNumero(String texto, {VoidCallback? onPressed}) {
    return ElevatedButton(
      onPressed: () {
        int cantidad = int.tryParse(texto) ?? 0;
        setState(() {
          if (productoSeleccionado != null) {
            // Caso 1: Ya hay un producto seleccionado → sumar al mismo
            productoSeleccionado!['cantidad'] =
                (productoSeleccionado!['cantidad'] as int) + cantidad;

            productoSeleccionado!['total'] =
                (productoSeleccionado!['cantidad'] as int) *
                (productoSeleccionado!['precio'] as double);

            _recalcularTotales();
          } else {
            // Caso 2: No hay producto seleccionado → guardamos en buffer
            cantidadBuffer =
                cantidadBuffer * 10 + cantidad; // permite 12, 123, etc
          }
        });
      },
      style: _botonEstilo(),
      child: Text(
        texto,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _agregarProducto(Map<String, dynamic> producto) {
    setState(() {
      final index = ordenes.indexWhere(
        (item) => item['nombre'] == producto['nombre'],
      );

      int cantidad = (cantidadBuffer > 0) ? cantidadBuffer : 1;

      if (index >= 0) {
        ordenes[index]['cantidad'] += cantidad;
        ordenes[index]['total'] =
            ordenes[index]['cantidad'] * ordenes[index]['precio'];
        productoSeleccionado = ordenes[index];
      } else {
        var nuevo = {
          "nombre": producto['nombre'],
          "precio": producto['precio'],
          "cantidad": cantidad,
          "total": producto['precio'] * cantidad,
          "nota": "",
        };
        ordenes.add(nuevo);
        productoSeleccionado = nuevo;
      }

      cantidadBuffer = 0; // limpiamos el buffer
      _recalcularTotales();
    });
  }

  void _agregarNota() {
    if (productoSeleccionado == null) return;

    TextEditingController notaController = TextEditingController(
      text: productoSeleccionado!['nota'] ?? "",
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Agregar nota"),
          content: SingleChildScrollView(
            child: TextField(
              controller: notaController,
              decoration: const InputDecoration(hintText: "Escribe la nota..."),
              maxLines: 3,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  productoSeleccionado!['nota'] = notaController.text;
                });
                Navigator.pop(context);
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  // Aumentar cantidad del producto seleccionado
  void _incrementarCantidad() {
    if (productoSeleccionado != null) {
      setState(() {
        productoSeleccionado!['cantidad'] =
            (productoSeleccionado!['cantidad'] as int) + 1;
        productoSeleccionado!['total'] =
            (productoSeleccionado!['cantidad'] as int) *
            (productoSeleccionado!['precio'] as double);

        _recalcularTotales();
      });
    }
  }

  // Disminuir cantidad del producto seleccionado
  void _disminuirCantidad() {
    if (productoSeleccionado != null) {
      setState(() {
        if ((productoSeleccionado!['cantidad'] as int) > 1) {
          productoSeleccionado!['cantidad'] =
              (productoSeleccionado!['cantidad'] as int) - 1;
          productoSeleccionado!['total'] =
              (productoSeleccionado!['cantidad'] as int) *
              (productoSeleccionado!['precio'] as double);
        } else {
          ordenes.remove(productoSeleccionado);
          productoSeleccionado = null;
        }

        _recalcularTotales();
      });
    }
  }

  // Eliminar producto seleccionado
  void _eliminarProducto() {
    if (productoSeleccionado != null) {
      setState(() {
        ordenes.remove(productoSeleccionado);
        productoSeleccionado = null;
        _recalcularTotales();
      });
    }
  }

  // Recalcular totales
  void _recalcularTotales() {
    totalItems = ordenes.fold(0, (sum, item) => sum + item['cantidad'] as int);
    totalGeneral = ordenes.fold(
      0.0,
      (sum, item) => sum + (item['total'] as double),
    );
  }

  void _cambiarTiempo() {
    if (productoSeleccionado == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Seleccionar tiempo"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    productoSeleccionado!['tiempo'] = 1;
                  });
                  Navigator.pop(context);
                },
                child: const Text("1"),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    productoSeleccionado!['tiempo'] = 2;
                  });
                  Navigator.pop(context);
                },
                child: const Text("2"),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    productoSeleccionado!['tiempo'] = 3;
                  });
                  Navigator.pop(context);
                },
                child: const Text("3"),
              ),
            ],
          ),
        );
      },
    );
  }
}
