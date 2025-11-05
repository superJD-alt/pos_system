import 'package:flutter/foundation.dart';

class MesaState extends ChangeNotifier {
  static final MesaState _instance = MesaState._internal();

  factory MesaState() {
    return _instance;
  }

  MesaState._internal();

  // Mapa para almacenar el estado de cada mesa
  final Map<int, bool> _mesasOcupadas = {};

  // ✅ NUEVO: Mapa separado para pedidos ENVIADOS a cocina
  final Map<int, List<Map<String, dynamic>>> _pedidosEnviadosPorMesa = {};

  // Obtener pedidos ENVIADOS de una mesa (los que tienen mesero y fecha)
  List<Map<String, dynamic>> obtenerPedidosEnviados(int numeroMesa) {
    return _pedidosEnviadosPorMesa[numeroMesa] ?? [];
  }

  // Mapa para almacenar los pedidos de cada mesa
  final Map<int, List<Map<String, dynamic>>> _pedidosPorMesa = {};

  // Mapa para almacenar el número de comensales por mesa
  final Map<int, int> _comensalesPorMesa = {};

  // ✅ NUEVO: Variable para guardar el nombre del mesero actual
  String _meseroActual = "";

  // ✅ NUEVO: Getter para obtener el mesero actual
  String get meseroActual => _meseroActual;

  // ✅ NUEVO: Método para establecer el mesero después del login
  void establecerMesero(String nombreMesero) {
    _meseroActual = nombreMesero;
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

  void ocuparMesa(int numeroMesa, int comensales) {
    _mesasOcupadas[numeroMesa] = true;
    _comensalesPorMesa[numeroMesa] = comensales;
    // Si no existe, inicializar lista vacía
    if (!_pedidosPorMesa.containsKey(numeroMesa)) {
      _pedidosPorMesa[numeroMesa] = [];
    }
    notifyListeners();
  }

  void liberarMesa(int numeroMesa) {
    _mesasOcupadas[numeroMesa] = false;
    _pedidosPorMesa.remove(numeroMesa);
    _pedidosEnviadosPorMesa.remove(numeroMesa); // ✅ También limpiar enviados
    _comensalesPorMesa.remove(numeroMesa);
    notifyListeners();
  }

  // Obtener pedidos de una mesa específica
  List<Map<String, dynamic>> obtenerPedidos(int numeroMesa) {
    return _pedidosPorMesa[numeroMesa] ?? [];
  }

  // ✅ MODIFICADO: Guardar pedidos de una mesa CON el mesero
  void guardarPedidos(int numeroMesa, List<Map<String, dynamic>> pedidos) {
    _pedidosPorMesa[numeroMesa] = List.from(pedidos);
    notifyListeners();
  }

  // ✅ NUEVO: Método para agregar un pedido con toda la info
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

    // ✅ Limpiar pedidos locales después de enviar
    _pedidosPorMesa[numeroMesa] = [];

    notifyListeners();
  }

  // Obtener comensales de una mesa
  int obtenerComensales(int numeroMesa) {
    return _comensalesPorMesa[numeroMesa] ?? 0;
  }

  // Limpiar todo el estado (opcional, para reiniciar la app)
  void limpiarTodo() {
    _mesasOcupadas.clear();
    _pedidosPorMesa.clear();
    _pedidosEnviadosPorMesa.clear(); // ✅ Limpiar también los pedidos enviados
    _comensalesPorMesa.clear();
    _meseroActual = ""; // ✅ Limpiar también el mesero
    notifyListeners();
  }

  // ✅ AGREGAR al final de la clase MesaState, antes del último }

  // Obtener resumen completo de una mesa
  Map<String, dynamic> obtenerResumenMesa(int numeroMesa) {
    final ocupada = estaMesaOcupada(numeroMesa);
    final comensales = obtenerComensales(numeroMesa);
    final pedidosLocales = obtenerPedidos(numeroMesa);
    final pedidosEnviados = obtenerPedidosEnviados(numeroMesa);

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
}
