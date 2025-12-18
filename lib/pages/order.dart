import 'package:flutter/material.dart';
import 'package:pos_system/models/pedido.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pos_system/models/producto.dart';
import 'package:pos_system/pages/mesa_state.dart';
import 'package:uuid/uuid.dart';
import 'package:pos_system/pages/turno_state.dart';
import 'package:pos_system/models/cuenta_cerrada.dart';
import 'package:printing/printing.dart';
import 'package:pos_system/pages/pdf_generator.dart';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pos_system/models/auth_dialog.dart';
import 'package:pos_system/pages/pdf_generator.dart'; // Tu generador actual
import 'package:pos_system/models/printer_service.dart'; // El servicio que creamos
import 'package:native_pdf_renderer/native_pdf_renderer.dart'; // Para convertir PDF a Imagen
import 'package:pos_system/models/welirkca_printer.dart';

class OrderPage extends StatefulWidget {
  final int numeroMesa;
  final int comensales;

  const OrderPage({
    super.key,
    required this.numeroMesa,
    required this.comensales,
  });

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final MesaState mesaState = MesaState();
  final TurnoState turnoState = TurnoState();
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; //instancia para Firestore

  String categoriaSeleccionada = "Todos"; // valor inicial
  String? subcategoriaSeleccionada; // ← NUEVO: Para bebidas
  bool mostrandoSubcategorias =
      false; // ← NUEVO: Para mostrar/ocultar subcategorías

  int cantidadBuffer = 0; //contador para botones
  int totalItems = 0; //contador de total de items
  double totalGeneral = 0.0; //contador de totalGeneral

  final WelirkcaPrinterService _printer = WelirkcaPrinterService(); //impresora

  // ✅ NUEVAS VARIABLES para manejo de caja
  String? _cajaActualId;
  String? _cajeroNombre;
  bool _cargandoCaja = false;

  String? _ultimoFolioGenerado;

  Map<String, dynamic>?
  productoSeleccionado; //producto seleccionado actualmente en la tabla de orden

  // ✅ NUEVO: Lista de productos desde Firestore
  List<Producto> todosLosProductos = [];
  List<String> categorias = [];
  bool cargandoProductos = true;

  List<Map<String, dynamic>> ordenes =
      []; //lista para productos en tabla de ordenes

  Set<int> productosEnviados = {};

  @override
  void initState() {
    super.initState();
    // Cargar los pedidos existentes de esta mesa
    _cargarPedidosExistentes();
    _cargarProductosDesdeFirestore(); //cargar productos de la base de datos
    _verificarCajaAbierta();
  }

  Future<void> _cargarProductosDesdeFirestore() async {
    try {
      setState(() => cargandoProductos = true);

      List<Producto> productos = [];

      // 1️⃣ Cargar PLATILLOS
      print('🔍 Cargando platillos...');
      QuerySnapshot snapshotPlatillos = await _firestore
          .collection('platillos')
          .where('disponible', isEqualTo: true)
          .get();

      List<Producto> platillos = snapshotPlatillos.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;

        // Convertir precio si es String
        if (data['precio'] is String) {
          data['precio'] = double.tryParse(data['precio']) ?? 0.0;
        }

        // Asegurar que tenga el campo 'tipo'
        data['tipo'] = 'platillo';

        return Producto.fromFirestore(doc.id, data);
      }).toList();

      print('✅ Platillos cargados: ${platillos.length}');

      // 2️⃣ Cargar BEBIDAS
      print('🔍 Cargando bebidas...');
      QuerySnapshot snapshotBebidas = await _firestore
          .collection('bebidas')
          .where('disponible', isEqualTo: true)
          .get();

      List<Producto> bebidas = snapshotBebidas.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;

        // Convertir precio si es String
        if (data['precio'] is String) {
          data['precio'] = double.tryParse(data['precio']) ?? 0.0;
        }

        // Asegurar que tenga el campo 'tipo'
        data['tipo'] = 'bebida';

        return Producto.fromFirestore(doc.id, data);
      }).toList();

      print('✅ Bebidas cargadas: ${bebidas.length}');

      // 3️⃣ Combinar
      productos = [...platillos, ...bebidas];

      // 4️⃣ Ordenar
      productos.sort((a, b) {
        // Primero por tipo (platillos antes que bebidas)
        int tipoComparison = (a.tipo ?? 'platillo').compareTo(
          b.tipo ?? 'platillo',
        );
        if (tipoComparison != 0) return tipoComparison;

        // Luego por categoría
        int categoriaComparison = a.categoria.compareTo(b.categoria);
        if (categoriaComparison != 0) return categoriaComparison;

        // Finalmente por nombre
        return a.nombre.compareTo(b.nombre);
      });

      // 5️⃣ Crear categorías jerárquicas
      List<String> listaCategorias = _crearCategoriasJerarquicas(productos);

      setState(() {
        todosLosProductos = productos;
        categorias = listaCategorias;
        cargandoProductos = false;
      });

      print('📂 Categorías: $listaCategorias');
    } catch (e) {
      print('❌ Error: $e');
      setState(() => cargandoProductos = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar productos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// ✅ MODIFICADO: Crear categorías sin separador de bebidas
  List<String> _crearCategoriasJerarquicas(List<Producto> productos) {
    List<String> resultado = ['Todos'];

    // Obtener categorías de platillos (sin incluir bebidas)
    Set<String> categoriasPlatillos = productos
        .where((p) => p.tipo == 'platillo')
        .map((p) => p.categoria)
        .toSet();

    resultado.addAll(categoriasPlatillos.toList()..sort());

    // Agregar solo el botón "Bebidas" (sin subcategorías aquí)
    resultado.add('Bebidas');

    return resultado;
  }

  // Modifica el método productosFiltrados
  List<Producto> get productosFiltrados {
    if (categoriaSeleccionada == "Todos") {
      return todosLosProductos.where((p) => p.tipo == 'platillo').toList();
    }

    if (categoriaSeleccionada == "Bebidas") {
      // ✅ NUEVO: Retornar TODAS las bebidas ordenadas por categoría
      List<Producto> bebidas = todosLosProductos
          .where((p) => p.tipo == 'bebida')
          .toList();

      // Ordenar por categoría y luego por nombre
      bebidas.sort((a, b) {
        int catComparison = a.categoria.compareTo(b.categoria);
        if (catComparison != 0) return catComparison;
        return a.nombre.compareTo(b.nombre);
      });

      return bebidas;
    }

    return todosLosProductos
        .where((p) => p.categoria == categoriaSeleccionada)
        .toList();
  }

  void _cargarPedidosExistentes() {
    print('\n╔════════════════════════════════════════╗');
    print(
      '║  🔄 CARGANDO PEDIDOS DE MESA ${widget.numeroMesa.toString().padLeft(2)}     ║',
    );
    print('╚════════════════════════════════════════╝');

    setState(() {
      // Limpiar completamente
      ordenes.clear();
      productoSeleccionado = null;

      // 1. Cargar pedidos ENVIADOS a cocina (los que tienen mesero, fecha, etc)
      final pedidosEnviados = mesaState.obtenerPedidosEnviados(
        widget.numeroMesa,
      );
      print('📨 Pedidos ENVIADOS encontrados: ${pedidosEnviados.length}');

      for (int i = 0; i < pedidosEnviados.length; i++) {
        var pedido = pedidosEnviados[i];
        final alimentos = pedido["alimentos"] ?? [];
        print('   📦 Pedido $i tiene ${alimentos.length} alimento(s):');

        for (var alimento in alimentos) {
          print(
            '      • ${alimento['nombre']} x${alimento['cantidad']} (Enviado ✓)',
          );
          ordenes.add({
            "nombre": alimento['nombre'],
            "precio": alimento['precio'],
            "cantidad": alimento['cantidad'],
            "total":
                (alimento['precio'] as double) * (alimento['cantidad'] as int),
            "nota": alimento['nota'] ?? "",
            "enviado": true, // Ya fue enviado a cocina
            "tiempo": alimento['tiempo'] ?? 1,
          });
        }
      }

      // 2. Cargar pedidos LOCALES (los que aún no se enviaron)
      final pedidosLocales = mesaState.obtenerPedidos(widget.numeroMesa);
      print('📋 Pedidos LOCALES encontrados: ${pedidosLocales.length}');

      for (var pedido in pedidosLocales) {
        print('   • ${pedido['nombre']} x${pedido['cantidad']} (No enviado /)');
      }

      ordenes.addAll(List.from(pedidosLocales));

      print('─────────────────────────────────────────');
      print('✅ TOTAL en lista ordenes: ${ordenes.length}');
      print(
        '   - Enviados: ${ordenes.where((o) => o['enviado'] == true).length}',
      );
      print(
        '   - No enviados: ${ordenes.where((o) => o['enviado'] != true).length}',
      );

      _recalcularTotales();

      print('💰 Total items: $totalItems');
      print('💵 Total general: \$${totalGeneral.toStringAsFixed(2)}');
      print('╚════════════════════════════════════════╝\n');
    });
  }

  @override
  void dispose() {
    // Guardar los pedidos al salir de la página
    _guardarPedidosLocales();
    super.dispose();
  }

  void _guardarPedidos() {
    _guardarPedidosLocales();
  }

  // Método para guardar pedidos locales (productos que aún NO se enviaron a cocina)
  void _guardarPedidosLocales() {
    // Separar productos enviados y no enviados
    final productosNoEnviados = ordenes
        .where((item) => item['enviado'] != true)
        .toList();

    // Guardar solo los productos NO enviados en el estado local
    // Usamos una clave especial para diferenciarlos de los pedidos enviados
    if (productosNoEnviados.isNotEmpty) {
      mesaState.guardarPedidos(widget.numeroMesa, productosNoEnviados);
    } else {
      // Si no hay productos no enviados, limpiar los pedidos locales
      mesaState.guardarPedidos(widget.numeroMesa, []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _guardarPedidosLocales();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.grey,
        resizeToAvoidBottomInset: false,
        body: LayoutBuilder(
          builder: (context, constraints) {
            // ✅ Determinar tipo de pantalla (igual que panel_meseros.dart)
            bool isSmallScreen = constraints.maxWidth < 600;
            bool isMediumScreen =
                constraints.maxWidth >= 600 && constraints.maxWidth < 1200;
            bool isLargeScreen = constraints.maxWidth >= 1200;

            // ✅ Configuración responsiva
            double horizontalPadding = isSmallScreen
                ? 2
                : isMediumScreen
                ? 4
                : 8;
            int crossAxisCount = isSmallScreen
                ? 2
                : isMediumScreen
                ? 3
                : 4;
            double childAspectRatio = isSmallScreen ? 0.75 : 0.80;

            return Column(
              children: [
                // ================== HEADER SUPERIOR ==================
                _buildHeader(isSmallScreen, isMediumScreen),
                const SizedBox(height: 5),

                // ================== FILA PRINCIPAL ==================
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(horizontalPadding),
                    child: isSmallScreen
                        ? _buildSmallScreenLayout(
                            crossAxisCount,
                            childAspectRatio,
                          )
                        : _buildLargeScreenLayout(
                            crossAxisCount,
                            childAspectRatio,
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ✅ NUEVO: Layout para pantallas pequeñas (móviles)
  Widget _buildSmallScreenLayout(int crossAxisCount, double childAspectRatio) {
    return Column(
      children: [
        // Grid de productos arriba
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildCategoriasBar(),
              const SizedBox(height: 5),
              Expanded(
                child: Container(
                  color: Colors.grey[300],
                  padding: const EdgeInsets.all(10),
                  child: cargandoProductos
                      ? const Center(child: CircularProgressIndicator())
                      : _buildProductosGrid(crossAxisCount, childAspectRatio),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Panel de órdenes abajo
        Expanded(flex: 1, child: _buildLeftPanel()),
      ],
    );
  }

  // ✅ NUEVO: Layout para pantallas grandes (tablets/escritorio)
  Widget _buildLargeScreenLayout(int crossAxisCount, double childAspectRatio) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Panel izquierdo (órdenes)
        Expanded(flex: 1, child: _buildLeftPanel()),

        const SizedBox(width: 10),

        // Panel derecho (productos)
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildCategoriasBar(),
              const SizedBox(height: 5),
              Expanded(
                child: Container(
                  color: Colors.grey[300],
                  padding: const EdgeInsets.all(10),
                  child: cargandoProductos
                      ? const Center(child: CircularProgressIndicator())
                      : _buildProductosGrid(crossAxisCount, childAspectRatio),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(bool isSmallScreen, bool isMediumScreen) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        height: isSmallScreen ? 45 : 50,
        width: double.infinity,
        color: Colors.white,
        child: Row(
          children: [
            ElevatedButton.icon(
              onPressed: () {
                _guardarPedidosLocales();
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back, size: isSmallScreen ? 14 : 16),
              label: Text(
                'ATRÁS',
                style: TextStyle(fontSize: isSmallScreen ? 10 : 12),
              ),
              style: _botonEstilo(
                minWidth: isSmallScreen ? 80 : 100,
                minHeight: isSmallScreen ? 40 : 45,
              ),
            ),
            const Spacer(),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 8 : 12,
                vertical: isSmallScreen ? 4 : 6,
              ),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Mesa ${widget.numeroMesa}',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 11 : 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${widget.comensales} comensales',
                    style: TextStyle(fontSize: isSmallScreen ? 9 : 10),
                  ),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _agregarProductoPersonalizado,
              icon: Icon(
                Icons.add_circle_rounded,
                size: isSmallScreen ? 16 : 20,
              ),
              label: Text(
                isSmallScreen ? 'AGREGAR' : 'AGREGAR PRODUCTO',
                style: TextStyle(
                  fontSize: isSmallScreen ? 10 : 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 8 : 16,
                  vertical: isSmallScreen ? 6 : 10,
                ),
                elevation: 4,
                minimumSize: Size(
                  isSmallScreen ? 100 : 140,
                  isSmallScreen ? 40 : 45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ NUEVO: Barra de categorías
  Widget _buildCategoriasBar() {
    return Container(
      height: 70,
      color: Colors.grey[300],
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categorias.length,
        itemBuilder: (context, index) {
          return _categoriaBoton(categorias[index]);
        },
      ),
    );
  }

  Widget _buildProductosGrid(int crossAxisCount, double childAspectRatio) {
    final productos = productosFiltrados;

    if (productos.isEmpty) {
      return const Center(
        child: Text(
          'No hay productos en esta categoría',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    if (categoriaSeleccionada == "Bebidas") {
      return _buildBebidasConDivisores(
        productos,
        crossAxisCount,
        childAspectRatio,
      );
    }

    return GridView.builder(
      itemCount: productos.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final producto = productos[index];
        return _buildProductoCard(producto);
      },
    );
  }

  Widget _buildProductoCard(Producto producto) {
    Color getCategoryColor(String categoria) {
      switch (categoria.toLowerCase()) {
        case 'entradas':
          return const Color(0xFFFF6B6B);
        case 'ensaladas':
          return const Color(0xFF51CF66);
        case 'sopas':
          return const Color(0xFFFFD93D);
        case 'quesos':
          return const Color(0xFFFFA94D);
        case 'papas':
          return const Color(0xFFD4A574);
        case 'costillas':
          return const Color(0xFFE03131);
        case 'molcajetes':
          return const Color(0xFFFF8787);
        case 'cortes':
          return const Color(0xFFC92A2A);
        case 'tacos':
          return const Color(0xFF94D82D);
        case 'volcanes':
          return const Color(0xFFFF6B35);
        case 'bebidas':
        case 'cocteleria':
        case 'cerveza':
        case 'tequila':
        case 'whisky':
        case 'brandy':
        case 'mezcales':
        case 'vinos':
        case 'sin alcohol':
          return const Color(0xFF4DABF7);
        case 'postres':
          return const Color(0xFFFF69B4);
        default:
          return const Color(0xFF868E96);
      }
    }

    final categoryColor = getCategoryColor(producto.categoria);
    final bool tieneImagen =
        producto.imagen != null && producto.imagen!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: categoryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => _agregarProductoDesdeFirestore(producto),
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.pressed)) {
              return categoryColor.withOpacity(0.9);
            }
            return Colors.white;
          }),
          foregroundColor: WidgetStateProperty.all(Colors.black87),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: categoryColor, width: 3),
            ),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ), // ✅ Reducido vertical de 12 a 8
          ),
          elevation: WidgetStateProperty.resolveWith<double>((states) {
            if (states.contains(WidgetState.pressed)) return 2;
            return 6;
          }),
          overlayColor: WidgetStateProperty.all(categoryColor.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize:
              MainAxisSize.min, // ✅ CRÍTICO: Evita expansión innecesaria
          children: [
            // ✅ IMAGEN O ICONO - Tamaño fijo más pequeño
            if (tieneImagen)
              Container(
                width: 70, // ✅ Reducido de 80 a 70 para dar más espacio
                height: 70, // ✅ Reducido de 80 a 70
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: categoryColor, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: categoryColor.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    producto.imagen!,
                    width: 70, // ✅ Actualizado
                    height: 70, // ✅ Actualizado,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              categoryColor.withOpacity(0.2),
                              categoryColor.withOpacity(0.4),
                            ],
                          ),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                            color: categoryColor,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              categoryColor.withOpacity(0.2),
                              categoryColor.withOpacity(0.4),
                            ],
                          ),
                        ),
                        child: Icon(
                          _getIconForCategory(producto.categoria),
                          size: 35, // ✅ Reducido de 40 a 35
                          color: categoryColor,
                        ),
                      );
                    },
                  ),
                ),
              )
            else
              Container(
                width: 70, // ✅ Reducido de 80 a 70
                height: 70, // ✅ Reducido de 80 a 70
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      categoryColor.withOpacity(0.2),
                      categoryColor.withOpacity(0.4),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: categoryColor, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: categoryColor.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(
                  _getIconForCategory(producto.categoria),
                  size: 35, // ✅ Reducido de 40 a 35
                  color: categoryColor,
                ),
              ),

            const SizedBox(height: 6), // ✅ Reducido de 8 a 6
            // ✅ NOMBRE DEL PRODUCTO - Altura dinámica según si tiene gramos
            Container(
              height: producto.gramos != null
                  ? 32
                  : 36, // ✅ 32px si tiene gramos, 36px si no
              alignment: Alignment.center,
              child: Text(
                producto.nombre,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12, // ✅ Reducido de 13 a 12
                  height: 1.1, // ✅ Reducido de 1.2 a 1.1
                  letterSpacing: 0.3,
                ),
              ),
            ),

            const SizedBox(height: 3), // ✅ Reducido a 3 cuando hay gramos
            // ✅ GRAMOS (si aplica)
            if (producto.gramos != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ), // ✅ Padding mínimo
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: categoryColor.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  '${producto.gramos}g',
                  style: TextStyle(
                    fontSize: 10, // ✅ Reducido de 11 a 10
                    color: categoryColor.withOpacity(0.9),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 3), // ✅ Reducido a 3 cuando hay gramos
            ],

            // Si no hay gramos, usar más espacio antes del precio
            if (producto.gramos == null) const SizedBox(height: 4),

            // ✅ PRECIO con diseño premium
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 5,
              ), // ✅ Padding reducido
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2ECC71).withOpacity(0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                "\$${(producto.precio is int ? (producto.precio as int).toDouble() : producto.precio).toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 14, // ✅ Reducido de 15 a 14
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cancelarPedidoConAutorizacion() async {
    // 1. Validar que haya un producto seleccionado
    if (productoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Selecciona un producto primero'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final bool estaEnviado = productoSeleccionado!['enviado'] == true;

    // Guardar datos del producto ANTES de cualquier operación
    final nombreProducto = productoSeleccionado!['nombre'] as String;
    final cantidadProducto = productoSeleccionado!['cantidad'] as int;
    final totalProducto = productoSeleccionado!['total'] as double;

    // 2. Si el producto ya fue enviado, requiere autorización
    if (estaEnviado) {
      final resultado = await showDialog<Map<String, dynamic>?>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AuthDialog(
          titulo: 'Cancelar pedido enviado',
          mensaje:
              'Este producto ya fue enviado a cocina/barra. Se requiere autorización de administrador.',
        ),
      );

      if (resultado == null || resultado['autorizado'] != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Cancelación no autorizada'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      final String adminNombre = resultado['adminNombre'] ?? 'Administrador';
      print('✅ Cancelación autorizada por: $adminNombre');
    }

    // 3. Mostrar confirmación final
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange, size: 28),
            SizedBox(width: 10),
            Text('Confirmar cancelación'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Está seguro que desea cancelar este producto?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        estaEnviado ? Icons.check_circle : Icons.pending,
                        color: estaEnviado ? Colors.green : Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        estaEnviado ? 'Enviado a cocina/barra' : 'No enviado',
                        style: TextStyle(
                          fontSize: 12,
                          color: estaEnviado ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Text(
                    nombreProducto,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Cantidad: $cantidadProducto',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    'Total: \$${totalProducto.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            if (estaEnviado) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange, width: 1.5),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '⚠️ Este producto ya fue enviado a cocina/barra',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No, mantener'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sí, cancelar producto'),
          ),
        ],
      ),
    );

    if (confirmar != true) {
      return;
    }

    print('\n══════════════════════════════════════════');
    print('🔥 INICIANDO CANCELACIÓN DE PRODUCTO');
    print('══════════════════════════════════════════');
    print('📝 Producto: $nombreProducto');
    print('🔢 Cantidad: $cantidadProducto');
    print('📨 Enviado: $estaEnviado');
    print('🏠 Mesa: ${widget.numeroMesa}');

    // 4. ELIMINAR DEL ESTADO LOCAL PRIMERO
    setState(() {
      print('\n📋 Estado ANTES de eliminar:');
      print('   Total órdenes: ${ordenes.length}');

      // Eliminar de la lista local
      ordenes.removeWhere(
        (item) =>
            item['nombre'] == nombreProducto &&
            item['cantidad'] == cantidadProducto &&
            item['enviado'] == estaEnviado,
      );

      print('📋 Estado DESPUÉS de eliminar:');
      print('   Total órdenes: ${ordenes.length}');

      // Limpiar selección
      productoSeleccionado = null;

      // Recalcular totales
      _recalcularTotales();
    });

    // 5. SI ERA ENVIADO, ELIMINAR DE MESASTATE
    if (estaEnviado) {
      print('\n🗑️ Eliminando de MesaState...');
      mesaState.eliminarProductoEnviado(
        widget.numeroMesa,
        nombreProducto,
        cantidadProducto,
      );

      // ⏳ Dar tiempo para que notifyListeners() se propague
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // 6. Guardar cambios en pedidos locales
    print('\n💾 Guardando pedidos locales...');
    _guardarPedidosLocales();

    // 7. FORZAR RECARGA COMPLETA
    print('\n🔄 Forzando recarga completa...');
    _cargarPedidosExistentes();

    // 8. Verificar resultado
    print('\n✅ Verificación final:');
    print('   Total órdenes después de recargar: ${ordenes.length}');
    print(
      '   Pedidos enviados en MesaState: ${mesaState.obtenerPedidosEnviados(widget.numeroMesa).length}',
    );
    print('══════════════════════════════════════════\n');

    // 9. Mostrar confirmación de éxito
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      estaEnviado
                          ? '✓ Pedido enviado cancelado'
                          : '✓ Pedido cancelado',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      '$cantidadProducto x $nombreProducto (\$${totalProducto.toStringAsFixed(2)})',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildBebidasConDivisores(
    List<Producto> bebidas,
    int crossAxisCount,
    double childAspectRatio,
  ) {
    Map<String, List<Producto>> bebidasPorCategoria = {};
    for (var bebida in bebidas) {
      if (!bebidasPorCategoria.containsKey(bebida.categoria)) {
        bebidasPorCategoria[bebida.categoria] = [];
      }
      bebidasPorCategoria[bebida.categoria]!.add(bebida);
    }

    Color getBebidasCategoryColor(String categoria) {
      switch (categoria.toLowerCase()) {
        case 'cocteleria':
          return const Color(0xFFFF6B9D);
        case 'cerveza':
          return const Color(0xFFFFA94D);
        case 'tequila':
          return const Color(0xFF51CF66);
        case 'whisky':
          return const Color(0xFFD4A574);
        case 'brandy':
          return const Color(0xFFB8860B);
        case 'mezcales':
          return const Color(0xFF8B4513);
        case 'vinos':
          return const Color(0xFF8E44AD);
        case 'sin alcohol':
          return const Color(0xFF4ECDC4);
        default:
          return const Color(0xFF4DABF7);
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: bebidasPorCategoria.length,
      itemBuilder: (context, index) {
        String categoria = bebidasPorCategoria.keys.elementAt(index);
        List<Producto> productosCategoria = bebidasPorCategoria[categoria]!;
        Color categoryColor = getBebidasCategoryColor(categoria);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              margin: const EdgeInsets.only(bottom: 10, left: 8, right: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [categoryColor.withOpacity(0.9), categoryColor],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: categoryColor.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      _getIconForCategory(categoria),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          categoria.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          '${productosCategoria.length} producto${productosCategoria.length != 1 ? 's' : ''}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${productosCategoria.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: productosCategoria.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: childAspectRatio,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemBuilder: (context, productIndex) {
                  return _buildProductoCard(productosCategoria[productIndex]);
                },
              ),
            ),

            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  // ✅ NUEVO: Obtener icono según categoría
  IconData _getIconForCategory(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'entradas':
        return Icons.restaurant;
      case 'ensaladas':
        return Icons.eco;
      case 'sopas':
        return Icons.soup_kitchen;
      case 'quesos':
        return Icons.set_meal;
      case 'papas':
        return Icons.fastfood;
      case 'costillas':
      case 'cortes':
        return Icons.outdoor_grill;
      case 'molcajetes':
        return Icons.rice_bowl;
      case 'tacos':
        return Icons.lunch_dining;
      case 'volcanes':
        return Icons.local_fire_department;
      case 'bebidas':
        return Icons.local_drink;
      case 'postres':
        return Icons.cake;
      default:
        return Icons.restaurant_menu;
    }
  }

  // ✅ NUEVO: Agregar producto desde Firestore
  // ✅ MODIFICADO: Agregar producto desde Firestore con término en la nota
  void _agregarProductoDesdeFirestore(Producto producto) async {
    // Verificar si es un corte para solicitar el término
    if (producto.categoria.toLowerCase() == 'cortes prime') {
      final termino = await _seleccionarTerminoCoccion(producto.nombre);
      if (termino == null) return; // Usuario canceló

      setState(() {
        int cantidad = (cantidadBuffer > 0) ? cantidadBuffer : 1;

        // ✅ NUEVO: Crear la nota automáticamente con el término
        String notaConTermino = "TÉRMINO: $termino";

        // Buscar si ya existe el mismo corte con el mismo término
        final index = ordenes.indexWhere(
          (item) =>
              item['nombre'] == producto.nombre &&
              item['nota'] == notaConTermino &&
              item['enviado'] != true,
        );

        if (index >= 0) {
          ordenes[index]['cantidad'] += cantidad;
          ordenes[index]['total'] =
              ordenes[index]['cantidad'] * ordenes[index]['precio'];
          productoSeleccionado = ordenes[index];
        } else {
          var nuevo = {
            "nombre": producto.nombre,
            "precio": producto.precio,
            "cantidad": cantidad,
            "total": producto.precio * cantidad,
            "nota": notaConTermino, // ✅ Nota automática con el término
            "enviado": false,
            "productoId": producto.id,
            "categoria": producto.categoria,
            "tiempo": 1,
          };
          ordenes.add(nuevo);
          productoSeleccionado = nuevo;
        }

        cantidadBuffer = 0;
        _recalcularTotales();
      });
    } else {
      // Para productos que NO son cortes, comportamiento normal
      setState(() {
        final index = ordenes.indexWhere(
          (item) =>
              item['nombre'] == producto.nombre && item['enviado'] != true,
        );

        int cantidad = (cantidadBuffer > 0) ? cantidadBuffer : 1;

        if (index >= 0) {
          ordenes[index]['cantidad'] += cantidad;
          ordenes[index]['total'] =
              ordenes[index]['cantidad'] * ordenes[index]['precio'];
          productoSeleccionado = ordenes[index];
        } else {
          var nuevo = {
            "nombre": producto.nombre,
            "precio": producto.precio,
            "cantidad": cantidad,
            "total": producto.precio * cantidad,
            "nota": "",
            "enviado": false,
            "productoId": producto.id,
            "categoria": producto.categoria,
            "tiempo": 1,
          };
          ordenes.add(nuevo);
          productoSeleccionado = nuevo;
        }

        cantidadBuffer = 0;
        _recalcularTotales();
      });
    }
  }

  // ✅ Panel izquierdo con tabla de órdenes, totales y botones
  Widget _buildLeftPanel() {
    return Column(
      children: [
        // ===== TABLA DE ORDENES (más compacta) =====
        Container(
          height: 300, // ✅ Reducido de 350 a 280
          child: Container(
            color: Colors.grey[100],
            width: double.infinity,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.grey[400]),
                headingRowHeight: 35, // ✅ NUEVO: Altura de encabezado reducida
                dataRowMinHeight: 30, // ✅ NUEVO: Altura mínima de fila
                dataRowMaxHeight: 35, // ✅ NUEVO: Altura máxima de fila
                columnSpacing: 15, // ✅ NUEVO: Espaciado entre columnas reducido
                horizontalMargin: 8, // ✅ NUEVO: Margen horizontal reducido
                border: TableBorder.symmetric(),
                columns: const [
                  DataColumn(
                    label: Text('Cant', style: TextStyle(fontSize: 11)),
                  ), // ✅ Texto más pequeño
                  DataColumn(label: Text('C', style: TextStyle(fontSize: 11))),
                  DataColumn(
                    label: Text('Descripción', style: TextStyle(fontSize: 11)),
                  ),
                  DataColumn(label: Text('T', style: TextStyle(fontSize: 11))),
                  DataColumn(
                    label: Text('Precio', style: TextStyle(fontSize: 11)),
                  ),
                  DataColumn(
                    label: Text('Total', style: TextStyle(fontSize: 11)),
                  ),
                ],
                rows: ordenes.expand((item) {
                  bool seleccionado = productoSeleccionado == item;

                  final mainRow = DataRow(
                    selected: seleccionado,
                    onSelectChanged: (val) {
                      setState(() {
                        productoSeleccionado = item;
                      });
                    },
                    cells: [
                      DataCell(
                        Text(
                          item['cantidad'].toString(),
                          style: const TextStyle(fontSize: 11),
                        ),
                      ), // ✅ Texto pequeño
                      DataCell(
                        SizedBox(
                          width: 10,
                          child: Text(
                            item['enviado'] == true ? '*' : '/',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: item['enviado'] == true
                                  ? Colors.green
                                  : Colors.black,
                              fontWeight: item['enviado'] == true
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 11, // ✅ Texto pequeño
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          item['nombre'],
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 10,
                          child: Text(
                            item['tiempo']?.toString() ?? '1',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          "\$${item['precio']}",
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                      DataCell(
                        Text(
                          "\$${(item['precio'] * item['cantidad']).toStringAsFixed(2)}",
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ],
                  );

                  if ((item['nota'] ?? "").isNotEmpty) {
                    final noteRow = DataRow(
                      cells: [
                        const DataCell(SizedBox()),
                        const DataCell(SizedBox()),
                        DataCell(
                          Text(
                            "Nota: ${item['nota']}",
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                              fontSize: 10, // ✅ Nota más pequeña
                            ),
                          ),
                        ),
                        const DataCell(SizedBox()),
                        const DataCell(SizedBox()),
                        const DataCell(SizedBox()),
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

        // ===== CONTENEDOR TOTAL (más compacto) =====
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ), // ✅ Padding reducido
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  readOnly: true,
                  controller: TextEditingController(
                    text: totalItems.toString(),
                  ),
                  style: const TextStyle(fontSize: 12), // ✅ Texto más pequeño
                  decoration: const InputDecoration(
                    labelText: 'Total ítems',
                    labelStyle: TextStyle(fontSize: 11), // ✅ Label más pequeño
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ), // ✅ Padding reducido
                    isDense: true, // ✅ NUEVO: Hacer el campo más denso
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  readOnly: true,
                  controller: TextEditingController(
                    text: "\$${totalGeneral.toStringAsFixed(2)}",
                  ),
                  style: const TextStyle(fontSize: 12), // ✅ Texto más pequeño
                  decoration: const InputDecoration(
                    labelText: 'Total general',
                    labelStyle: TextStyle(fontSize: 11),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 5),

        // ===== BOTONES POS (más compactos y responsivos) =====
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0), // ✅ Padding reducido
            child: LayoutBuilder(
              builder: (context, constraints) {
                const int crossAxisCount = 4;
                const double mainAxisSpacing = 7; // ✅ Reducido de 8 a 6
                const double crossAxisSpacing = 7; // ✅ Reducido de 8 a 6

                final double itemWidth =
                    (constraints.maxWidth -
                        crossAxisSpacing * (crossAxisCount - 1)) /
                    crossAxisCount;
                const double desiredItemHeight = 65.0; // ✅ Reducido de 65 a 50
                final double responsiveChildAspectRatio =
                    itemWidth / desiredItemHeight;

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: GridView.count(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: mainAxisSpacing,
                      crossAxisSpacing: crossAxisSpacing,
                      childAspectRatio: responsiveChildAspectRatio,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _botonAccion(Icons.local_offer, "NOTA", _agregarNota),
                        _botonAccion(
                          Icons.cancel,
                          "CANCELAR",
                          _cancelarPedidoConAutorizacion,
                        ),
                        _botonAccion(
                          Icons.access_time,
                          "TIEMPOS",
                          _cambiarTiempo,
                        ),
                        _botonAccion(Icons.delete, "BORRAR", _eliminarProducto),
                        _botonAccion(
                          Icons.swap_horiz,
                          "TRANSFERIR",
                          _transferirMesa,
                        ),
                        _botonNumero(
                          "1",
                          onPressed: () {
                            if (productoSeleccionado != null) {
                              setState(() {
                                productoSeleccionado!['cantidad'] = 1;
                                productoSeleccionado!['total'] =
                                    (productoSeleccionado!['cantidad'] as int) *
                                    (productoSeleccionado!['precio'] as double);
                                _recalcularTotales();
                              });
                            }
                          },
                        ),
                        _botonNumero("2"),
                        _botonNumero("3"),
                        _botonAccion(Icons.print, "COMANDA", _enviarComanda),
                        _botonNumero("4"),
                        _botonNumero("5"),
                        _botonNumero("6"),
                        _botonAccion(
                          Icons.receipt_long,
                          'CUENTA',
                          _cerrarCuentaYGenerarPdf,
                        ),
                        _botonNumero("7"),
                        _botonNumero("8"),
                        _botonNumero("9"),
                        const SizedBox.shrink(),
                        _botonAccion(Icons.add, "+", _incrementarCantidad),
                        _botonAccion(Icons.remove, "-", _disminuirCantidad),
                        _botonNumero("0"),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // ===================== MÉTODOS HELPER =====================

  ButtonStyle _botonEstilo({double minWidth = 70, double minHeight = 25}) {
    // ✅ Valores por defecto reducidos
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
      style: ButtonStyle(
        minimumSize: WidgetStateProperty.all(const Size(60, 35)),
        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.pressed)) {
            return Colors.blue.shade700;
          }
          return Colors.white;
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.pressed)) {
            return Colors.white;
          }
          return Colors.black87;
        }),
        elevation: WidgetStateProperty.resolveWith<double>((states) {
          if (states.contains(WidgetState.pressed)) {
            return 1;
          }
          return 2; // ✅ Reducido de 3 a 2
        }),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4), // ✅ Reducido de 8 a 6
            side: BorderSide(
              color: Colors.grey.shade300,
              width: 1,
            ), // ✅ Reducido de 1.5 a 1
          ),
        ),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(
            horizontal: 2,
            vertical: 4,
          ), // ✅ Padding muy reducido
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 16), // ✅ Reducido de 20 a 16
          if (texto.isNotEmpty) const SizedBox(height: 2),
          if (texto.isNotEmpty)
            Flexible(
              child: Text(
                texto,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10, // ✅ Reducido de 15 a 10
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Muestra el diálogo de vista previa y opciones de impresión/guardado del PDF
  Future<void> _mostrarDialogoTicket(
    Uint8List pdfBytes,
    CuentaCerrada cuenta,
  ) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(
              'Ticket Mesa ${cuenta.numeroMesa} Cerrada',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          content: SizedBox(
            width: 400, // Ajusta el tamaño para tablet
            height: 500, // Ajusta el tamaño
            child: PdfPreview(
              build: (format) => pdfBytes,
              allowPrinting: true,
              allowSharing: true,
              maxPageWidth: 700,
              pdfFileName:
                  'Ticket_Mesa_${cuenta.numeroMesa}_${cuenta.fechaCierre.millisecondsSinceEpoch}.pdf',
              canChangeOrientation: false,
              canChangePageFormat: false,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Aceptar y Volver',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // ✅ MEJORADO: Botón de categoría con mejor diseño
  Widget _categoriaBoton(String nombre, {IconData? icono}) {
    final bool seleccionado = categoriaSeleccionada == nombre;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      child: GestureDetector(
        onTap: () {
          setState(() {
            categoriaSeleccionada = nombre;
            mostrandoSubcategorias = false;
            subcategoriaSeleccionada = null;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: seleccionado
                ? LinearGradient(
                    colors: [Colors.blue.shade600, Colors.blue.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: seleccionado ? null : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: seleccionado ? Colors.blue.shade700 : Colors.grey.shade300,
              width: seleccionado ? 2.5 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: seleccionado
                    ? Colors.blue.withOpacity(0.4)
                    : Colors.black.withOpacity(0.05),
                blurRadius: seleccionado ? 10 : 4,
                offset: Offset(0, seleccionado ? 4 : 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icono != null) ...[
                Icon(
                  icono,
                  size: 22,
                  color: seleccionado ? Colors.white : Colors.grey[700],
                ),
                const SizedBox(width: 8),
              ],
              Text(
                nombre,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: seleccionado ? Colors.white : Colors.grey[800],
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ NUEVO: Diálogo para seleccionar término de cocción
  Future<String?> _seleccionarTerminoCoccion(String nombreCorte) async {
    final terminos = [
      {'nombre': 'Azul', 'icono': Icons.ac_unit, 'color': Colors.blue},
      {
        'nombre': 'Sellado',
        'icono': Icons.local_fire_department,
        'color': Colors.orange,
      },
      {
        'nombre': 'Inglés',
        'icono': Icons.restaurant,
        'color': Colors.red.shade300,
      },
      {
        'nombre': 'Término Medio',
        'icono': Icons.thermostat,
        'color': Colors.pink,
      },
      {
        'nombre': '3/4',
        'icono': Icons.whatshot,
        'color': Colors.brown.shade400,
      },
      {
        'nombre': 'Bien Cocido',
        'icono': Icons.local_fire_department,
        'color': Colors.brown.shade700,
      },
    ];

    return await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Encabezado
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.red.shade700, Colors.red.shade500],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.outdoor_grill,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Selecciona el Término',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              nombreCorte,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Grid de términos
                Expanded(
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.3,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                        ),
                    itemCount: terminos.length,
                    itemBuilder: (context, index) {
                      final termino = terminos[index];
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.pop(
                            context,
                            termino['nombre'] as String,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: termino['color'] as Color,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (termino['color'] as Color)
                                      .withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  termino['icono'] as IconData,
                                  size: 40,
                                  color: termino['color'] as Color,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  termino['nombre'] as String,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: termino['color'] as Color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Botón cancelar
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'CANCELAR',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Método para agregar un producto personalizado que no está en el menú
  void _agregarProductoPersonalizado() {
    // Controladores para los campos del formulario
    final TextEditingController nombreController = TextEditingController();
    final TextEditingController precioController = TextEditingController();
    final TextEditingController cantidadController = TextEditingController(
      text: '1',
    );
    final TextEditingController notaController = TextEditingController();

    // Variable para mostrar el total calculado
    double totalCalculado = 0.0;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Función para calcular el total
            void calcularTotal() {
              final precio = double.tryParse(precioController.text) ?? 0.0;
              final cantidad = int.tryParse(cantidadController.text) ?? 0;
              setDialogState(() {
                totalCalculado = precio * cantidad;
              });
            }

            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    Icons.add_shopping_cart,
                    color: Colors.blue.shade700,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Agregar Producto Personalizado',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Container(
                  width: 400,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mensaje informativo
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Usa este formulario para productos que no están en el menú',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Campo: Nombre del producto
                      TextField(
                        controller: nombreController,
                        decoration: InputDecoration(
                          labelText: 'Nombre del producto *',
                          hintText: 'Ej: Producto especial',
                          prefixIcon: const Icon(Icons.restaurant_menu),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        textCapitalization: TextCapitalization.words,
                        autofocus: true,
                      ),
                      const SizedBox(height: 16),

                      // Fila: Precio y Cantidad
                      Row(
                        children: [
                          // Campo: Precio
                          Expanded(
                            child: TextField(
                              controller: precioController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: InputDecoration(
                                labelText: 'Precio *',
                                hintText: '0.00',
                                prefixIcon: const Icon(Icons.attach_money),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                              onChanged: (value) => calcularTotal(),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Campo: Cantidad
                          Expanded(
                            child: TextField(
                              controller: cantidadController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Cantidad *',
                                hintText: '1',
                                prefixIcon: const Icon(Icons.shopping_basket),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                              onChanged: (value) => calcularTotal(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Campo: Nota (opcional)
                      TextField(
                        controller: notaController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Nota (opcional)',
                          hintText: 'Ej: Sin cebolla, término medio...',
                          prefixIcon: const Icon(Icons.note),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: 20),

                      // Mostrar total calculado
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade400,
                              Colors.green.shade600,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'TOTAL:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Text(
                              '\$${totalCalculado.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Nota de campos requeridos
                      const Text(
                        '* Campos requeridos',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                // Botón Cancelar
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'CANCELAR',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),

                // Botón Agregar
                ElevatedButton.icon(
                  onPressed: () {
                    // Validaciones
                    final nombre = nombreController.text.trim();
                    final precioText = precioController.text.trim();
                    final cantidadText = cantidadController.text.trim();

                    if (nombre.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            '❌ El nombre del producto es requerido',
                          ),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }

                    final precio = double.tryParse(precioText);
                    if (precio == null || precio <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('❌ Ingresa un precio válido mayor a 0'),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }

                    final cantidad = int.tryParse(cantidadText);
                    if (cantidad == null || cantidad <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            '❌ Ingresa una cantidad válida mayor a 0',
                          ),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }

                    // Cerrar el diálogo
                    Navigator.pop(dialogContext);

                    // Agregar el producto a la orden
                    setState(() {
                      final total = precio * cantidad;
                      final nota = notaController.text.trim();

                      final nuevoProducto = {
                        "nombre": nombre,
                        "precio": precio,
                        "cantidad": cantidad,
                        "total": total,
                        "nota": nota,
                        "enviado": false,
                        "categoria": "Personalizado",
                        "tiempo": 1,
                      };

                      ordenes.add(nuevoProducto);
                      productoSeleccionado = nuevoProducto;
                      _recalcularTotales();
                    });

                    // Mostrar confirmación
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '✓ $cantidad x $nombre agregado (\$${totalCalculado.toStringAsFixed(2)})',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 3),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_circle, size: 20),
                  label: const Text(
                    'AGREGAR',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 4,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ✅ MEJORADO: Botones numéricos
  Widget _botonNumero(String texto, {VoidCallback? onPressed}) {
    return ElevatedButton(
      onPressed:
          onPressed ??
          () {
            int cantidad = int.tryParse(texto) ?? 0;
            setState(() {
              if (productoSeleccionado != null) {
                productoSeleccionado!['cantidad'] =
                    (productoSeleccionado!['cantidad'] as int) + cantidad;
                productoSeleccionado!['total'] =
                    (productoSeleccionado!['cantidad'] as int) *
                    (productoSeleccionado!['precio'] as double);
                _recalcularTotales();
              } else {
                cantidadBuffer = cantidadBuffer * 10 + cantidad;
              }
            });
          },
      style: ButtonStyle(
        minimumSize: WidgetStateProperty.all(
          const Size(70, 45),
        ), // ✅ Reducido de 90x30
        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.pressed)) {
            return Colors.green.shade600;
          }
          return Colors.white;
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.pressed)) {
            return Colors.white;
          }
          return Colors.black87;
        }),
        elevation: WidgetStateProperty.resolveWith<double>((states) {
          if (states.contains(WidgetState.pressed)) {
            return 1;
          }
          return 2; // ✅ Reducido de 4 a 2
        }),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6), // ✅ Reducido de 8 a 6
            side: BorderSide(
              color: Colors.green.shade300,
              width: 1.5,
            ), // ✅ Reducido de 2 a 1.5
          ),
        ),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ), // ✅ Reducido de 20 a 16
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
          "enviado": false,
          "categoria": producto['categoria'],
          "tiempo": 1,
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
      if (productoSeleccionado!['enviado'] == true) {
        _mostrarMensajeBloqueo();
        return;
      }
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
      if (productoSeleccionado!['enviado'] == true) {
        _mostrarMensajeBloqueo();
        return;
      }
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
      if (productoSeleccionado!['enviado'] == true) {
        _mostrarMensajeBloqueo();
        return;
      }
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

  // Mostrar mensaje cuando se intenta modificar un producto enviado
  void _mostrarMensajeBloqueo() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("⚠️ Acción no permitida"),
          content: const Text(
            "No se puede modificar un producto ya enviado a cocina",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Aceptar"),
            ),
          ],
        );
      },
    );
  }

  void _enviarComanda() {
    // 1. Contar productos NO enviados
    final productosNoEnviados = ordenes
        .where((item) => item['enviado'] != true)
        .toList();

    if (productosNoEnviados.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Sin productos nuevos"),
            content: const Text("No hay productos nuevos para enviar a cocina"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Aceptar"),
              ),
            ],
          );
        },
      );
      return;
    }

    final String numMesa = widget.numeroMesa.toString();
    final int numComensales = widget.comensales;
    final String numPedido =
        'CMA-${DateTime.now().millisecondsSinceEpoch % 10000}';
    mesaState.guardarFolioMesa(widget.numeroMesa, numPedido);

    // Mostrar diálogo de confirmación
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("📋 Confirmar envío de comanda"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Se enviarán ${productosNoEnviados.length} producto(s) a cocina/barra:",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...productosNoEnviados.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    "• ${item['cantidad']}x ${item['nombre']}",
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "⚠️ Una vez enviados, NO podrás modificar ni eliminar estos productos.",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                // Separar productos por destino
                final productosCocina = productosNoEnviados
                    .where((p) => !_esBarra(p))
                    .toList();
                final productosBarra = productosNoEnviados
                    .where((p) => _esBarra(p))
                    .toList();

                try {
                  // ✅ GUARDAR EN FIRESTORE (colección 'ordenesCocina')
                  if (productosCocina.isNotEmpty) {
                    await _guardarOrdenCocina(
                      id: '${numPedido}-COCINA',
                      destino: 'cocina',
                      productos: productosCocina,
                    );
                  }

                  if (productosBarra.isNotEmpty) {
                    await _guardarOrdenCocina(
                      id: '${numPedido}-BARRA',
                      destino: 'barra',
                      productos: productosBarra,
                    );
                  }

                  // GENERACIÓN E IMPRESIÓN DE TICKETS
                  if (productosCocina.isNotEmpty) {
                    final String comandaCocina = _generarComandaTicket(
                      productosAImprimir: productosCocina,
                      numMesa: numMesa,
                      numComensales: numComensales,
                      destino: 'Cocina',
                      numPedido: numPedido,
                      mesaState: mesaState,
                    );
                    _imprimirComanda(comandaCocina);
                  }

                  if (productosBarra.isNotEmpty) {
                    final String comandaBarra = _generarComandaTicket(
                      productosAImprimir: productosBarra,
                      numMesa: numMesa,
                      numComensales: numComensales,
                      destino: 'Barra',
                      numPedido: numPedido,
                      mesaState: mesaState,
                    );
                    _imprimirComanda(comandaBarra);
                  }

                  // ACTUALIZAR ESTADO LOCAL
                  setState(() {
                    final alimentosEnviados = productosNoEnviados.map((item) {
                      return {
                        "nombre": item['nombre'],
                        "cantidad": item['cantidad'],
                        "precio": item['precio'],
                        "nota": item['nota'] ?? "",
                        "tiempo": item['tiempo'] ?? 1,
                        "categoria": item['categoria'] ?? "General",
                      };
                    }).toList();

                    mesaState.agregarPedido(
                      widget.numeroMesa,
                      alimentosEnviados,
                    );

                    for (var item in ordenes) {
                      if (item['enviado'] != true) {
                        item['enviado'] = true;
                      }
                    }
                  });

                  // Mostrar mensaje de éxito
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "✓ Comanda $numPedido enviada a Cocina/Barra",
                        ),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                } catch (e) {
                  print('❌ Error al enviar comanda: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("❌ Error al enviar comanda: $e"),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text("Enviar"),
            ),
          ],
        );
      },
    );
  }

  // ✅ NUEVO MÉTODO: Guardar en la colección correcta 'ordenesCocina'
  Future<void> _guardarOrdenCocina({
    required String id,
    required String destino,
    required List<Map<String, dynamic>> productos,
  }) async {
    try {
      final mesero = mesaState.meseroActual.isNotEmpty
          ? mesaState.meseroActual
          : 'Mesero Genérico';

      final turnoId = turnoState.turnoActual;

      // Preparar productos con el campo 'entregado' en false
      final productosParaFirestore = productos.map((p) {
        return {
          'nombre': p['nombre'] ?? '',
          'cantidad': p['cantidad'] ?? 1,
          'precio': p['precio'] ?? 0.0,
          'nota': p['nota'] ?? '',
          'tiempo': p['tiempo'] ?? 1,
          'categoria': p['categoria'] ?? 'General',
          'entregado': false, // ✅ Campo requerido por KitchenOrdersPage
        };
      }).toList();

      final ordenData = {
        'id': id,
        'numeroMesa': widget.numeroMesa,
        'mesero': mesero,
        'comensales': widget.comensales,
        'horaComanda': FieldValue.serverTimestamp(), // ✅ Campo requerido
        'destino': destino,
        'estado': 'en_cocina', // ✅ Estado correcto
        'productos': productosParaFirestore,
        'turnoId': turnoId,
      };

      // ✅ Guardar en la colección 'ordenesCocina'
      await _firestore.collection('ordenesCocina').doc(id).set(ordenData);

      print('✅ Orden guardada en ordenesCocina: $id');
      print('   Destino: $destino');
      print('   Productos: ${productos.length}');
    } catch (e) {
      print('❌ Error al guardar orden en ordenesCocina: $e');
      rethrow;
    }
  }

  // Método auxiliar para determinar si es barra (ya lo tienes)
  bool _esBarra(Map<String, dynamic> producto) {
    final categoria = (producto['categoria'] as String?)?.toLowerCase() ?? '';
    return categoria.contains('cerveza') ||
        categoria.contains('brandy') ||
        categoria.contains('tequila') ||
        categoria.contains('mezcales') ||
        categoria.contains('sin alcohol') ||
        categoria.contains('cocteleria') ||
        categoria.contains('vinos') ||
        categoria.contains('whisky');
  }

  Future<void> _guardarComandaEnFirestore({
    required String id,
    required String destino,
    required List<Map<String, dynamic>> productos,
  }) async {
    try {
      final mesero = mesaState.meseroActual.isNotEmpty
          ? mesaState.meseroActual
          : 'Mesero Genérico';

      final turnoId = turnoState.turnoActual;

      final totalProductos = productos.fold<int>(
        0,
        (sum, p) => sum + (p['cantidad'] as int),
      );

      final productosParaFirestore = productos.map((p) {
        return {
          'nombre': p['nombre'] ?? '',
          'cantidad': p['cantidad'] ?? 1,
          'precio': p['precio'] ?? 0.0,
          'nota': p['nota'] ?? '',
          'tiempo': p['tiempo'] ?? 1,
          'categoria': p['categoria'] ?? 'General',
        };
      }).toList();

      final comandaData = {
        'id': id,
        'numeroMesa': widget.numeroMesa,
        'mesero': mesero,
        'comensales': widget.comensales,
        'fechaHora': Timestamp.fromDate(DateTime.now()),
        'destino': destino,
        'estado': 'pendiente',
        'productos': productosParaFirestore,
        'totalProductos': totalProductos,
        'turnoId': turnoId,
      };

      // ✅ Guardar en Firestore
      await _firestore.collection('comandas').doc(id).set(comandaData);

      print('✅ Comanda guardada exitosamente: $id');
      print('   Destino: $destino');
      print('   Productos: $totalProductos');
      print('   Turno ID: ${turnoId ?? "Sin turno activo"}');
    } catch (e) {
      print('❌ Error al guardar comanda en Firestore: $e');
      print('   Stack trace: ${StackTrace.current}');
      rethrow; // Re-lanzar para que sea capturado en _enviarComanda
    }
  }

  String _generarComandaTicket({
    // 👈 Renombramos el parámetro para ser más claro.
    //    Si llamas a la función con SOLO productos de Cocina, esta lista será SOLO Cocina.
    required List<Map<String, dynamic>> productosAImprimir,
    required String numMesa,
    required int numComensales,
    required String numPedido,
    required String destino, // Usamos este valor para el encabezado
    required MesaState mesaState,
  }) {
    final String mesero = mesaState.meseroActual.isNotEmpty
        ? mesaState.meseroActual
        : 'Mesero Genérico';

    final now = DateTime.now();
    final String fechaHora = DateFormat('dd/MM/yyyy HH:mm:ss').format(now);

    // 💥 ELIMINAMOS ESTAS LÍNEAS. LA SEPARACIÓN DEBE HACERSE FUERA DEL MÉTODO.
    // final productosBarra = productos.where((p) => _esBarra(p)).toList();
    // final productosCocina = productos.where((p) => !_esBarra(p)).toList();

    final buffer = StringBuffer();

    // --- 1. ENCABEZADO DE COMANDA (Completo) ---
    buffer.writeln('********************************');
    buffer.writeln('*** PUNTO DE VENTA PARRILLA VILLA  ***');
    buffer.writeln('********************************');

    // ✅ Se imprime el destino para identificar el ticket
    buffer.writeln('===== DESTINO: ${destino.toUpperCase()} =====');
    buffer.writeln('--------------------------------');

    // ✅ Toda la info de la comanda
    buffer.writeln('PEDIDO No.: $numPedido');
    buffer.writeln('MESA: $numMesa');
    buffer.writeln('MESERO: ${mesero.toUpperCase()}');
    buffer.writeln('COMENSALES: $numComensales');
    buffer.writeln('FECHA/HORA: $fechaHora');
    buffer.writeln('--------------------------------');

    void _formatProductos(List<Map<String, dynamic>> lista) {
      for (var item in lista) {
        final cantidad = (item['cantidad'] as int).toString().padLeft(3);
        final nombre = item['nombre'] as String;
        final nota = item['nota'] as String?;

        buffer.writeln('(${cantidad}) ${nombre.toUpperCase()}');

        if (nota != null && nota.isNotEmpty) {
          buffer.writeln('    ** NOTA: $nota **');
        }
      }
    }

    // --- 2. SECCIÓN DE PRODUCTOS ESPECÍFICOS ---
    // 💥 Sustituimos las Secciones 2 y 3 por una única llamada,
    //    usando solo la lista que se nos pasó.
    if (productosAImprimir.isNotEmpty) {
      _formatProductos(productosAImprimir);
    }

    // --- 3. PIE DE PÁGINA ---
    buffer.writeln('\n================================');
    buffer.writeln('IMPRESO: ${DateFormat('HH:mm:ss').format(DateTime.now())}');
    buffer.writeln('********************************');

    return buffer.toString();
  }

  // 💡 Placeholder para la función de impresión real
  // En una aplicación real, usarías un paquete como 'esc_pos_utils' o 'blue_thermal_printer'.
  void _imprimirComanda(String comanda) {
    // Aquí iría la lógica para enviar la cadena 'comanda' a la impresora POS (red o bluetooth)

    // Por ahora, solo la mostramos en consola para verificar el formato
    print("--- INICIO IMPRESIÓN COMANDA ---");
    print(comanda);
    print("--- FIN IMPRESIÓN COMANDA ---");
  }

  void _procesarCuenta() {
    // Si no hay productos, no hacer nada
    if (ordenes.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Sin productos"),
            content: const Text("No hay productos en esta mesa"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Aceptar"),
              ),
            ],
          );
        },
      );
      return;
    }

    // Mostrar diálogo de confirmación
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("💳 Procesar cuenta"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Mesa ${widget.numeroMesa}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Total de productos: $totalItems",
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                "Total a pagar: \$${totalGeneral.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "⚠️ Esto liberará la mesa y guardará la cuenta en el resumen del turno.",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                // Cerrar el diálogo PRIMERO
                Navigator.pop(dialogContext);

                // ✅ NUEVO: Obtener información de la mesa antes de limpiar
                final turnoState = TurnoState();

                // Obtener pedidos enviados para calcular fecha de apertura
                final pedidosEnviados = mesaState.obtenerPedidosEnviados(
                  widget.numeroMesa,
                );
                DateTime fechaApertura = DateTime.now();

                if (pedidosEnviados.isNotEmpty) {
                  final primerPedido = pedidosEnviados.first;
                  fechaApertura =
                      DateTime.tryParse(primerPedido['fecha'] ?? '') ??
                      DateTime.now();
                }

                // ✅ NUEVO: Consolidar todos los productos de la cuenta
                List<Map<String, dynamic>> productosConsolidados = [];

                // Agregar productos enviados
                for (var pedido in pedidosEnviados) {
                  final alimentos = pedido['alimentos'] ?? [];
                  for (var alimento in alimentos) {
                    productosConsolidados.add({
                      'nombre': alimento['nombre'],
                      'cantidad': alimento['cantidad'],
                      'precio': alimento['precio'],
                      'nota': alimento['nota'] ?? '',
                    });
                  }
                }

                // Agregar productos locales no enviados (si existen)
                for (var orden in ordenes) {
                  if (orden['enviado'] != true) {
                    productosConsolidados.add({
                      'nombre': orden['nombre'],
                      'cantidad': orden['cantidad'],
                      'precio': orden['precio'],
                      'nota': orden['nota'] ?? '',
                    });
                  }
                }

                // ✅ NUEVO: Crear la cuenta cerrada
                final cuentaCerrada = CuentaCerrada(
                  id: const Uuid().v4(),
                  numeroMesa: widget.numeroMesa,
                  mesero: mesaState.meseroActual,
                  comensales: widget.comensales,
                  fechaApertura: fechaApertura,
                  fechaCierre: DateTime.now(),
                  productos: productosConsolidados,
                  totalItems: totalItems,
                  totalCuenta: totalGeneral,
                );

                // ✅ NUEVO: Guardar la cuenta en el turno
                turnoState.agregarCuentaCerrada(cuentaCerrada);

                // Limpiar y liberar la mesa
                setState(() {
                  ordenes.clear();
                  productoSeleccionado = null;
                  totalItems = 0;
                  totalGeneral = 0.0;
                  cantidadBuffer = 0;

                  // Liberar la mesa
                  mesaState.liberarMesa(widget.numeroMesa);
                });

                // Mostrar confirmación
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("✓ Cuenta procesada y guardada en el turno"),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );

                // Regresar a la pantalla anterior después de un momento
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text("Procesar"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _verificarCajaAbierta() async {
    try {
      setState(() => _cargandoCaja = true);

      final snapshot = await _firestore
          .collection('cajas')
          .where('estado', isEqualTo: 'abierta')
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final cajaDoc = snapshot.docs.first;
        setState(() {
          _cajaActualId = cajaDoc.id;
          _cajeroNombre = cajaDoc.data()['cajero'] ?? 'Cajero';
          _cargandoCaja = false;
        });
        print('✅ Caja abierta encontrada: $_cajaActualId');
      } else {
        setState(() {
          _cajaActualId = null;
          _cajeroNombre = null;
          _cargandoCaja = false;
        });
        print('⚠️ No hay caja abierta');
      }
    } catch (e) {
      print('❌ Error verificando caja: $e');
      setState(() => _cargandoCaja = false);
    }
  }

  Future<Map<String, dynamic>?> _mostrarDialogoDescuento({
    required double totalOriginal,
    required String numeroMesa,
  }) async {
    final formKey = GlobalKey<FormState>();
    final montoController = TextEditingController();
    final razonController = TextEditingController();
    String tipoDescuento = 'porcentaje';
    String categoriaDescuento = 'cortesia';
    double descuentoCalculado = 0.0;
    double totalConDescuento = totalOriginal;

    final NumberFormat currencyFormat = NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
      decimalDigits: 2,
    );

    return await showDialog<Map<String, dynamic>?>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          void calcularDescuento() {
            final valor = double.tryParse(montoController.text) ?? 0.0;
            if (tipoDescuento == 'porcentaje') {
              descuentoCalculado = totalOriginal * (valor / 100);
            } else {
              descuentoCalculado = valor;
            }
            totalConDescuento = totalOriginal - descuentoCalculado;
            if (totalConDescuento < 0) totalConDescuento = 0;
          }

          return AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.discount, color: Colors.purple),
                SizedBox(width: 8),
                Text('Aplicar Descuento'),
              ],
            ),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info de la cuenta
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.table_restaurant,
                                color: Colors.blue,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Mesa: $numeroMesa',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Total Original: ${currencyFormat.format(totalOriginal)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tipo de descuento
                    DropdownButtonFormField<String>(
                      value: tipoDescuento,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Descuento',
                        prefixIcon: Icon(Icons.percent),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'porcentaje',
                          child: Text('Porcentaje (%)'),
                        ),
                        DropdownMenuItem(
                          value: 'monto_fijo',
                          child: Text('Monto Fijo (\$)'),
                        ),
                      ],
                      onChanged: (v) {
                        setDialogState(() {
                          tipoDescuento = v!;
                          calcularDescuento();
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Categoría
                    DropdownButtonFormField<String>(
                      value: categoriaDescuento,
                      decoration: const InputDecoration(
                        labelText: 'Motivo del Descuento',
                        prefixIcon: Icon(Icons.category),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'cortesia',
                          child: Text('🎁 Cortesía de la Casa'),
                        ),
                        DropdownMenuItem(
                          value: 'promocion',
                          child: Text('🎉 Promoción'),
                        ),
                        DropdownMenuItem(
                          value: 'error_servicio',
                          child: Text('😔 Error en Servicio'),
                        ),
                        DropdownMenuItem(
                          value: 'error_cocina',
                          child: Text('🍳 Error en Cocina'),
                        ),
                        DropdownMenuItem(
                          value: 'cliente_frecuente',
                          child: Text('⭐ Cliente Frecuente'),
                        ),
                        DropdownMenuItem(
                          value: 'otro',
                          child: Text('📝 Otro Motivo'),
                        ),
                      ],
                      onChanged: (v) {
                        setDialogState(() => categoriaDescuento = v!);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Monto/Porcentaje
                    TextFormField(
                      controller: montoController,
                      decoration: InputDecoration(
                        labelText: tipoDescuento == 'porcentaje'
                            ? 'Porcentaje (%)'
                            : 'Monto (\$)',
                        prefixIcon: Icon(
                          tipoDescuento == 'porcentaje'
                              ? Icons.percent
                              : Icons.attach_money,
                        ),
                        border: const OutlineInputBorder(),
                        helperText: tipoDescuento == 'porcentaje'
                            ? 'Ejemplo: 10 para 10%'
                            : 'Ejemplo: 50 para \$50',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) {
                        setDialogState(() => calcularDescuento());
                      },
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Campo obligatorio';
                        }
                        final valor = double.tryParse(v);
                        if (valor == null || valor <= 0) {
                          return 'Debe ser mayor a 0';
                        }
                        if (tipoDescuento == 'porcentaje' && valor > 100) {
                          return 'No puede ser mayor a 100%';
                        }
                        if (tipoDescuento == 'monto_fijo' &&
                            valor > totalOriginal) {
                          return 'No puede ser mayor al total';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Razón
                    TextFormField(
                      controller: razonController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción Detallada',
                        prefixIcon: Icon(Icons.description),
                        border: OutlineInputBorder(),
                        helperText: 'Explica el motivo',
                      ),
                      maxLines: 3,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Campo obligatorio' : null,
                    ),
                    const SizedBox(height: 20),

                    // Resumen
                    if (montoController.text.isNotEmpty &&
                        double.tryParse(montoController.text) != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.purple.shade50,
                              Colors.purple.shade100,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.purple.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '📊 RESUMEN DEL DESCUENTO',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.purple,
                              ),
                            ),
                            const Divider(height: 16),
                            _buildResumenRow(
                              'Subtotal Original:',
                              currencyFormat.format(totalOriginal),
                              Colors.black87,
                            ),
                            _buildResumenRow(
                              'Descuento (${tipoDescuento == 'porcentaje' ? '${montoController.text}%' : 'Fijo'}):',
                              '- ${currencyFormat.format(descuentoCalculado)}',
                              Colors.red.shade700,
                            ),
                            const Divider(height: 16),
                            _buildResumenRow(
                              'TOTAL A PAGAR:',
                              currencyFormat.format(totalConDescuento),
                              Colors.green.shade700,
                              isBold: true,
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Advertencia
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'El descuento se registrará en la caja y ticket',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('Aplicar Descuento'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    calcularDescuento();
                    Navigator.pop(context, {
                      'tipo_descuento': tipoDescuento,
                      'categoria_descuento': categoriaDescuento,
                      'valor_descuento': double.parse(montoController.text),
                      'monto_descuento': descuentoCalculado,
                      'razon': razonController.text,
                      'total_original': totalOriginal,
                      'total_con_descuento': totalConDescuento,
                    });
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildResumenRow(
    String label,
    String value,
    Color color, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 18 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 PASO 6: NUEVO MÉTODO - Registrar descuento en caja
  Future<void> _registrarDescuentoEnCaja({
    required String cuentaId,
    required Map<String, dynamic> descuentoInfo,
  }) async {
    if (_cajaActualId == null) {
      print('⚠️ No hay caja abierta, no se registrará el descuento');
      return;
    }

    try {
      // 1. Registrar movimiento
      await _firestore.collection('movimientos_caja').add({
        'cajaId': _cajaActualId,
        'cuentaId': cuentaId,
        'fecha': FieldValue.serverTimestamp(),
        'tipo': 'descuento',
        'categoria': descuentoInfo['categoria_descuento'],
        'tipoDescuento': descuentoInfo['tipo_descuento'],
        'valorDescuento': descuentoInfo['valor_descuento'],
        'monto': descuentoInfo['monto_descuento'],
        'descripcion': descuentoInfo['razon'],
        'cajero': _cajeroNombre ?? 'Sistema',
        'mesa': widget.numeroMesa.toString(),
        'totalOriginal': descuentoInfo['total_original'],
        'totalConDescuento': descuentoInfo['total_con_descuento'],
      });

      // 2. Actualizar totales de caja
      await _firestore.collection('cajas').doc(_cajaActualId).update({
        'total_descuentos': FieldValue.increment(
          descuentoInfo['monto_descuento'],
        ),
        'efectivo_esperado': FieldValue.increment(
          -descuentoInfo['monto_descuento'],
        ),
      });

      print(
        '✅ Descuento registrado en caja: \$${descuentoInfo['monto_descuento']}',
      );
    } catch (e) {
      print('❌ Error registrando descuento en caja: $e');
      // No lanzamos error para no interrumpir el cierre de cuenta
    }
  }

  Future<void> _cerrarCuentaYGenerarPdf() async {
    if (ordenes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La orden está vacía. No se puede cerrar la cuenta.'),
        ),
      );
      return;
    }

    // 1. Preguntar si desea aplicar descuento
    final bool? aplicarDescuento = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Aplicar Descuento?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mesa ${widget.numeroMesa}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Total: \$${totalGeneral.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            const Text('¿Deseas aplicar un descuento antes de cerrar?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No, Cerrar Sin Descuento'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.discount),
            label: const Text('Sí, Aplicar Descuento'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (aplicarDescuento == null) return;

    double totalFinal = totalGeneral;
    Map<String, dynamic>? descuentoInfo;

    // 2. Si desea descuento, mostrar diálogo
    if (aplicarDescuento) {
      descuentoInfo = await _mostrarDialogoDescuento(
        totalOriginal: totalGeneral,
        numeroMesa: widget.numeroMesa.toString(),
      );

      if (descuentoInfo == null) return;
      totalFinal = descuentoInfo['total_con_descuento'];
    }

    // 3. Confirmación final
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Cierre de Cuenta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mesa ${widget.numeroMesa}'),
            const SizedBox(height: 12),
            if (descuentoInfo != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '💜 DESCUENTO APLICADO',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    const Divider(),
                    Text(
                      'Subtotal: \$${descuentoInfo['total_original'].toStringAsFixed(2)}',
                    ),
                    Text(
                      'Descuento: -\$${descuentoInfo['monto_descuento'].toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.red),
                    ),
                    const Divider(),
                    Text(
                      'Total a pagar: \$${totalFinal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Text(
                'Total: \$${totalFinal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar Cuenta'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // 4. Preparar datos de la cuenta
    final mesero = mesaState.meseroActual.isNotEmpty
        ? mesaState.meseroActual
        : 'Mesero Genérico';
    final idCuenta = const Uuid().v4();
    final fechaCierre = DateTime.now();
    final fechaApertura = fechaCierre.subtract(const Duration(minutes: 60));

    final productosList = ordenes.map<Map<String, dynamic>>((item) {
      return {
        'nombre': item['nombre'] as String,
        'precio': item['precio'] as double,
        'cantidad': item['cantidad'] as int,
        'total': item['total'] as double,
        'nota': item['nota'] ?? '',
        'enviado': item['enviado'] ?? false,
      };
    }).toList();

    final totalItems = productosList.fold(
      0,
      (sum, item) => sum + (item['cantidad'] as int),
    );

    final cuentaCerrada = CuentaCerrada(
      id: idCuenta,
      numeroMesa: widget.numeroMesa,
      mesero: mesero,
      comensales: widget.comensales,
      fechaApertura: fechaApertura,
      fechaCierre: fechaCierre,
      productos: productosList,
      totalItems: totalItems,
      totalCuenta: totalFinal,
      folio: mesaState.obtenerFolioMesa(widget.numeroMesa),
      descuentoAplicado: descuentoInfo != null ? true : null,
      descuentoTipo: descuentoInfo?['tipo_descuento'],
      descuentoCategoria: descuentoInfo?['categoria_descuento'],
      descuentoValor: descuentoInfo?['valor_descuento'],
      descuentoMonto: descuentoInfo?['monto_descuento'],
      descuentoRazon: descuentoInfo?['razon'],
      totalOriginal: descuentoInfo?['total_original'],
    );

    try {
      // 5. Guardar cuenta en Firestore
      await _firestore
          .collection('cuentasCerradas')
          .doc(idCuenta)
          .set(cuentaCerrada.toMap());

      // 6. Registrar descuento en caja (si aplica)
      if (descuentoInfo != null) {
        await _registrarDescuentoEnCaja(
          cuentaId: idCuenta,
          descuentoInfo: descuentoInfo,
        );
      }

      // 7. Registrar en TurnoState
      turnoState.agregarCuentaCerrada(cuentaCerrada);

      // 8. Generar PDF
      final pdfBytes = await generateTicketPdf(cuentaCerrada);

      // ════════════════════════════════════════════════════════════════
      // 🖨️ NUEVO: IMPRIMIR EN IMPRESORA TÉRMICA BLUETOOTH
      // ════════════════════════════════════════════════════════════════
      try {
        // Generar el ticket en formato texto
        final String ticketTexto = _generarTicketTexto(
          cuentaCerrada,
          descuentoInfo,
        );

        // Imprimir el texto
        await _printer.printText(ticketTexto);

        // Cortar el papel
        await _printer.cutPaper();

        // Hacer beep de confirmación
        await _printer.beep();

        print('✅ Ticket impreso en impresora térmica');
      } catch (e) {
        print('⚠️ Error al imprimir en impresora térmica: $e');
        // No interrumpir el flujo si falla la impresión
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('⚠️ Advertencia: Error al imprimir ticket: $e'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
      // ════════════════════════════════════════════════════════════════

      // 9. Mostrar diálogo con vista previa PDF
      await _mostrarDialogoTicket(pdfBytes, cuentaCerrada);

      // 10. Liberar mesa
      mesaState.liberarMesa(widget.numeroMesa);

      // 11. Navegar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              descuentoInfo != null
                  ? '✅ Cuenta cerrada con descuento de \$${descuentoInfo['monto_descuento'].toStringAsFixed(2)}'
                  : '✅ Cuenta cerrada e impresa exitosamente',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('❌ Error al cerrar cuenta: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al procesar el cierre de cuenta: $e')),
        );
      }
    }
  }

  // ════════════════════════════════════════════════════════════════
  // 🆕 MÉTODO NUEVO: Generar ticket en formato texto para impresora térmica
  // ════════════════════════════════════════════════════════════════
  String _generarTicketTexto(
    CuentaCerrada cuenta,
    Map<String, dynamic>? descuentoInfo,
  ) {
    final buffer = StringBuffer();

    // Ancho de 32 caracteres para impresora de 58mm
    buffer.writeln('================================');
    buffer.writeln('      PARRILLA VILLA');
    buffer.writeln('================================');
    buffer.writeln('');

    // Información de la mesa
    buffer.writeln('TICKET DE VENTA');
    buffer.writeln('--------------------------------');
    buffer.writeln('Mesa: ${cuenta.numeroMesa}');
    buffer.writeln('Mesero: ${cuenta.mesero}');
    buffer.writeln('Comensales: ${cuenta.comensales}');
    if (cuenta.folio != null) {
      buffer.writeln('Folio: ${cuenta.folio}');
    }
    buffer.writeln(
      'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(cuenta.fechaCierre)}',
    );
    buffer.writeln('--------------------------------');
    buffer.writeln('');

    // Productos
    buffer.writeln('PRODUCTOS:');
    buffer.writeln('--------------------------------');

    for (var producto in cuenta.productos) {
      final nombre = producto['nombre'] as String;
      final cantidad = producto['cantidad'] as int;
      final precio = producto['precio'] as double;
      final total = producto['total'] as double;

      // Línea del producto: "2x Producto     $100.00"
      buffer.writeln('${cantidad}x $nombre');
      buffer.writeln(
        '    \$${precio.toStringAsFixed(2)} x $cantidad = \$${total.toStringAsFixed(2)}',
      );

      // Nota si existe
      final nota = producto['nota'] as String?;
      if (nota != null && nota.isNotEmpty) {
        buffer.writeln('    Nota: $nota');
      }
    }

    buffer.writeln('--------------------------------');
    buffer.writeln('');

    // Totales
    if (descuentoInfo != null) {
      buffer.writeln(
        'Subtotal:    \$${descuentoInfo['total_original'].toStringAsFixed(2)}',
      );
      buffer.writeln(
        'Descuento:  -\$${descuentoInfo['monto_descuento'].toStringAsFixed(2)}',
      );
      buffer.writeln('  (${descuentoInfo['razon']})');
      buffer.writeln('--------------------------------');
    }

    buffer.writeln('');
    buffer.writeln('TOTAL:       \$${cuenta.totalCuenta.toStringAsFixed(2)}');
    buffer.writeln('');
    buffer.writeln('================================');
    buffer.writeln('   ¡Gracias por su visita!');
    buffer.writeln('      Vuelva pronto');
    buffer.writeln('================================');
    buffer.writeln('');

    return buffer.toString();
  }

  // Agregar este método en la clase _OrderPageState
  void _transferirMesa() {
    // Si no hay productos, no hacer nada
    if (ordenes.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Sin productos"),
            content: const Text("No hay productos para transferir"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Aceptar"),
              ),
            ],
          );
        },
      );
      return;
    }

    // Controlador para el número de mesa destino
    TextEditingController mesaDestinoController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("🔄 Transferir mesa"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Mesa actual: ${widget.numeroMesa}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Productos a transferir: $totalItems",
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  "Total: \$${totalGeneral.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: mesaDestinoController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Número de mesa destino",
                    hintText: "Ingresa el número de mesa",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "⚠️ Todos los productos se transferirán a la mesa destino.",
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                // Validar que se ingresó un número
                int? mesaDestino = int.tryParse(mesaDestinoController.text);

                if (mesaDestino == null) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("❌ Ingresa un número de mesa válido"),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }

                // Validar que no sea la misma mesa
                if (mesaDestino == widget.numeroMesa) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("❌ No puedes transferir a la misma mesa"),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }

                // Obtener pedidos de la mesa destino
                List<Map<String, dynamic>> pedidosDestino = List.from(
                  mesaState.obtenerPedidos(mesaDestino),
                );

                // Agregar los productos de la mesa actual a la mesa destino
                for (var producto in ordenes) {
                  // Buscar si el producto ya existe en la mesa destino
                  int index = pedidosDestino.indexWhere(
                    (p) =>
                        p['nombre'] == producto['nombre'] &&
                        p['enviado'] == producto['enviado'] &&
                        (p['nota'] ?? '') == (producto['nota'] ?? ''),
                  );

                  if (index >= 0) {
                    // Si existe, sumar las cantidades
                    pedidosDestino[index]['cantidad'] += producto['cantidad'];
                    pedidosDestino[index]['total'] =
                        pedidosDestino[index]['cantidad'] *
                        pedidosDestino[index]['precio'];
                  } else {
                    // Si no existe, agregar como nuevo producto (copia profunda)
                    pedidosDestino.add({
                      'nombre': producto['nombre'],
                      'precio': producto['precio'],
                      'cantidad': producto['cantidad'],
                      'total': producto['total'],
                      'nota': producto['nota'] ?? '',
                      'enviado': producto['enviado'] ?? false,
                      'tiempo': producto['tiempo'] ?? 1,
                      'imagen': producto['imagen'] ?? '',
                    });
                  }
                }

                // ORDEN CORRECTO DE OPERACIONES:

                // 1. Ocupar la mesa destino PRIMERO (si no está ocupada)
                if (!mesaState.estaMesaOcupada(mesaDestino)) {
                  int comensales = mesaState.obtenerComensales(
                    widget.numeroMesa,
                  );
                  if (comensales == 0) comensales = widget.comensales;
                  mesaState.ocuparMesa(mesaDestino, comensales);
                }

                // 2. Guardar pedidos en la mesa destino
                mesaState.guardarPedidos(mesaDestino, pedidosDestino);

                // 3. Liberar la mesa origen (esto eliminará los pedidos automáticamente)
                mesaState.liberarMesa(widget.numeroMesa);

                // 4. Cerrar el diálogo
                Navigator.pop(dialogContext);

                // 5. Limpiar el estado local
                setState(() {
                  ordenes.clear();
                  productoSeleccionado = null;
                  totalItems = 0;
                  totalGeneral = 0.0;
                  cantidadBuffer = 0;
                });

                // 6. Mostrar confirmación
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "✓ Productos transferidos a mesa $mesaDestino",
                    ),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );

                // 7. Regresar a la pantalla anterior CON UN DELAY MÁS LARGO
                // Esto permite que notifyListeners() se propague
                Future.delayed(const Duration(milliseconds: 800), () {
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text("Transferir"),
            ),
          ],
        );
      },
    );
  }
}
