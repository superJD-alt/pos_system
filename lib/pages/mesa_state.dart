import 'package:flutter/foundation.dart';

class MesaState extends ChangeNotifier {
  static final MesaState _instance = MesaState._internal();

  factory MesaState() {
    return _instance;
  }

  Map<int, String> _foliosMesa = {}; // mesa -> folio

  void guardarFolioMesa(int numeroMesa, String folio) {
    _foliosMesa[numeroMesa] = folio;
    notifyListeners();
  }

  String? obtenerFolioMesa(int numeroMesa) {
    return _foliosMesa[numeroMesa];
  }

  MesaState._internal();

  // Mapa para almacenar el estado de cada mesa
  final Map<int, bool> _mesasOcupadas = {};

  // ✅ NUEVO: Mapa para almacenar qué mesero ocupa cada mesa
  final Map<int, String> _meserosPorMesa = {};

  // Mapa separado para pedidos ENVIADOS a cocina
  final Map<int, List<Map<String, dynamic>>> _pedidosEnviadosPorMesa = {};

  // Obtener pedidos ENVIADOS de una mesa
  List<Map<String, dynamic>> obtenerPedidosEnviados(int numeroMesa) {
    return _pedidosEnviadosPorMesa[numeroMesa] ?? [];
  }

  // Mapa para almacenar los pedidos de cada mesa
  final Map<int, List<Map<String, dynamic>>> _pedidosPorMesa = {};

  // Mapa para almacenar el número de comensales por mesa
  final Map<int, int> _comensalesPorMesa = {};

  // Variable para guardar el nombre del mesero actual
  String _meseroActual = "";

  // Getter para obtener el mesero actual
  String get meseroActual => _meseroActual;

  // ✅ NUEVO: Obtener el mesero que ocupa una mesa específica
  String? obtenerMeseroDeMesa(int numeroMesa) {
    return _meserosPorMesa[numeroMesa];
  }

  // ✅ NUEVO: Verificar si el mesero actual puede acceder a una mesa
  bool puedeAccederMesa(int numeroMesa) {
    // Si la mesa no está ocupada, cualquiera puede acceder
    if (!estaMesaOcupada(numeroMesa)) {
      return true;
    }

    // Si está ocupada, solo el mesero que la ocupó puede acceder
    final meseroDeLaMesa = _meserosPorMesa[numeroMesa];
    return meseroDeLaMesa == _meseroActual;
  }

  // ✅ NUEVO: Obtener todas las mesas del mesero actual
  List<int> obtenerMesasDelMeseroActual() {
    return _meserosPorMesa.entries
        .where((entry) => entry.value == _meseroActual)
        .map((entry) => entry.key)
        .toList();
  }

  // ✅ NUEVO: Obtener mesas ocupadas por otros meseros
  List<int> obtenerMesasDeOtrosMeseros() {
    return _meserosPorMesa.entries
        .where(
          (entry) =>
              entry.value != _meseroActual && _mesasOcupadas[entry.key] == true,
        )
        .map((entry) => entry.key)
        .toList();
  }

  // Método para establecer el mesero después del login
  void establecerMesero(String nombreMesero) {
    _meseroActual = nombreMesero;
    print('👤 Mesero establecido: $_meseroActual');
    print('📊 Mesas actuales del mesero: ${obtenerMesasDelMeseroActual()}');
    notifyListeners();
  }

  bool estaMesaOcupada(int numeroMesa) {
    return _mesasOcupadas[numeroMesa] ?? false;
  }

  // Obtener todas las mesas actualmente ocupadas
  List<int> obtenerMesasOcupadas() {
    return _mesasOcupadas.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .toList();
  }

  // ✅ MODIFICADO: Registrar qué mesero ocupa la mesa
  void ocuparMesa(int numeroMesa, int comensales) {
    _mesasOcupadas[numeroMesa] = true;
    _comensalesPorMesa[numeroMesa] = comensales;
    _meserosPorMesa[numeroMesa] = _meseroActual; // 👈 NUEVO: Registrar mesero

    // Si no existe, inicializar lista vacía
    if (!_pedidosPorMesa.containsKey(numeroMesa)) {
      _pedidosPorMesa[numeroMesa] = [];
    }

    print(
      '🔵 Mesa $numeroMesa ocupada por $_meseroActual ($comensales comensales)',
    );
    notifyListeners();
  }

  // ✅ MODIFICADO: Limpiar también el registro del mesero
  void liberarMesa(int numeroMesa) {
    final mesero = _meserosPorMesa[numeroMesa];

    _mesasOcupadas[numeroMesa] = false;
    _pedidosPorMesa.remove(numeroMesa);
    _pedidosEnviadosPorMesa.remove(numeroMesa);
    _comensalesPorMesa.remove(numeroMesa);
    _foliosMesa.remove(numeroMesa);
    _meserosPorMesa.remove(numeroMesa); // 👈 NUEVO: Limpiar registro de mesero

    print('🟢 Mesa $numeroMesa liberada (era de $mesero)');
    notifyListeners();
  }

  // Obtener pedidos de una mesa específica
  List<Map<String, dynamic>> obtenerPedidos(int numeroMesa) {
    return _pedidosPorMesa[numeroMesa] ?? [];
  }

  // Guardar pedidos de una mesa
  void guardarPedidos(int numeroMesa, List<Map<String, dynamic>> pedidos) {
    _pedidosPorMesa[numeroMesa] = List.from(pedidos);
    notifyListeners();
  }

  // Método para agregar un pedido con toda la info
  void agregarPedido(int numeroMesa, List<Map<String, dynamic>> alimentos) {
    if (!_pedidosEnviadosPorMesa.containsKey(numeroMesa)) {
      _pedidosEnviadosPorMesa[numeroMesa] = [];
    }

    final pedido = {
      "mesero": _meseroActual,
      "fecha": DateTime.now().toIso8601String(),
      "alimentos": alimentos,
    };

    _pedidosEnviadosPorMesa[numeroMesa]!.add(pedido);

    // Limpiar pedidos locales después de enviar
    _pedidosPorMesa[numeroMesa] = [];

    notifyListeners();
  }

  // Obtener comensales de una mesa
  int obtenerComensales(int numeroMesa) {
    return _comensalesPorMesa[numeroMesa] ?? 0;
  }

  // ✅ MODIFICADO: Limpiar todo incluyendo registros de meseros
  void limpiarTodo() {
    _mesasOcupadas.clear();
    _pedidosPorMesa.clear();
    _pedidosEnviadosPorMesa.clear();
    _comensalesPorMesa.clear();
    _meserosPorMesa.clear(); // 👈 NUEVO: Limpiar meseros
    _meseroActual = "";
    notifyListeners();
  }

  // Obtener resumen completo de una mesa
  Map<String, dynamic> obtenerResumenMesa(int numeroMesa) {
    final ocupada = estaMesaOcupada(numeroMesa);
    final comensales = obtenerComensales(numeroMesa);
    final pedidosLocales = obtenerPedidos(numeroMesa);
    final pedidosEnviados = obtenerPedidosEnviados(numeroMesa);
    final mesero = _meserosPorMesa[numeroMesa]; // 👈 NUEVO

    int totalProductos = 0;
    double totalGeneral = 0.0;

    // Contar productos locales
    for (var pedido in pedidosLocales) {
      totalProductos += pedido['cantidad'] as int;
      totalGeneral += pedido['total'] as double;
    }

    // Contar productos enviados
    for (var pedidoEnviado in pedidosEnviados) {
      final alimentos = pedidoEnviado['alimentos'] as List;
      for (var alimento in alimentos) {
        totalProductos += alimento['cantidad'] as int;
        totalGeneral += (alimento['precio'] * alimento['cantidad']) as double;
      }
    }

    return {
      'ocupada': ocupada,
      'comensales': comensales,
      'totalProductos': totalProductos,
      'totalGeneral': totalGeneral,
      'pedidosLocales': pedidosLocales.length,
      'pedidosEnviados': pedidosEnviados.length,
      'mesero': mesero, // 👈 NUEVO: Incluir mesero en el resumen
      'esMesaPropia': mesero == _meseroActual, // 👈 NUEVO
    };
  }

  // Obtener estadísticas generales del restaurante
  Map<String, dynamic> obtenerEstadisticasGenerales() {
    int mesasOcupadas = 0;
    int totalComensales = 0;
    double ventaTotal = 0.0;

    for (var numeroMesa in _mesasOcupadas.keys) {
      if (_mesasOcupadas[numeroMesa] == true) {
        mesasOcupadas++;
        totalComensales += obtenerComensales(numeroMesa);

        final resumen = obtenerResumenMesa(numeroMesa);
        ventaTotal += resumen['totalGeneral'] as double;
      }
    }

    return {
      'mesasOcupadas': mesasOcupadas,
      'totalComensales': totalComensales,
      'ventaTotal': ventaTotal,
    };
  }

  void eliminarProductoEnviado(
    int numeroMesa,
    String nombreProducto,
    int cantidad,
  ) {
    print('🔍 Buscando producto para eliminar:');
    print('   Mesa: $numeroMesa');
    print('   Producto: $nombreProducto');
    print('   Cantidad: $cantidad');

    // Verificar si la mesa tiene pedidos enviados
    if (!_pedidosEnviadosPorMesa.containsKey(numeroMesa)) {
      print('⚠️ No hay pedidos enviados para la mesa $numeroMesa');
      return;
    }

    List<Map<String, dynamic>> pedidos = _pedidosEnviadosPorMesa[numeroMesa]!;
    print('📋 Total de pedidos enviados: ${pedidos.length}');

    bool productoEliminado = false;

    // Recorrer cada pedido
    for (int i = 0; i < pedidos.length; i++) {
      var pedido = pedidos[i];

      if (pedido['alimentos'] != null) {
        List<dynamic> alimentos = List.from(pedido['alimentos']);
        int alimentosAntes = alimentos.length;

        print('   📦 Pedido $i - Alimentos antes: $alimentosAntes');

        // Buscar y eliminar el producto
        alimentos.removeWhere((alimento) {
          bool coincide =
              alimento['nombre'] == nombreProducto &&
              alimento['cantidad'] == cantidad;

          if (coincide) {
            print(
              '   🗑️ ¡ENCONTRADO! Eliminando: ${alimento['nombre']} (${alimento['cantidad']})',
            );
            productoEliminado = true;
          }

          return coincide;
        });

        print('   📦 Pedido $i - Alimentos después: ${alimentos.length}');

        // Actualizar la lista de alimentos en el pedido
        pedido['alimentos'] = alimentos;
      }
    }

    // Eliminar pedidos que quedaron sin alimentos
    int pedidosAntes = pedidos.length;
    pedidos.removeWhere(
      (pedido) =>
          pedido['alimentos'] == null || (pedido['alimentos'] as List).isEmpty,
    );

    if (pedidos.length < pedidosAntes) {
      print('🧹 Se eliminaron ${pedidosAntes - pedidos.length} pedidos vacíos');
    }

    // Actualizar el mapa
    if (pedidos.isEmpty) {
      _pedidosEnviadosPorMesa.remove(numeroMesa);
      print(
        '🧹 Todos los pedidos enviados fueron eliminados de la mesa $numeroMesa',
      );
    } else {
      _pedidosEnviadosPorMesa[numeroMesa] = pedidos;
      print('💾 Pedidos actualizados: ${pedidos.length} pedidos restantes');
    }

    if (productoEliminado) {
      notifyListeners();
      print('✅ Producto eliminado exitosamente y listeners notificados');
    } else {
      print('⚠️ No se encontró el producto en pedidos enviados');
      print('   Verifica que el nombre y cantidad sean exactos');
    }
  }
}
