import 'package:flutter/foundation.dart';

class MesaState extends ChangeNotifier {
  static final MesaState _instance = MesaState._internal();

  factory MesaState() {
    return _instance;
  }

  MesaState._internal();

  // Mapa para almacenar el estado de cada mesa
  final Map<int, bool> _mesasOcupadas = {};

  // Mapa para almacenar los pedidos de cada mesa
  final Map<int, List<Map<String, dynamic>>> _pedidosPorMesa = {};

  // Mapa para almacenar el número de comensales por mesa
  final Map<int, int> _comensalesPorMesa = {};

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
    _comensalesPorMesa.remove(numeroMesa);
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

  // Obtener comensales de una mesa
  int obtenerComensales(int numeroMesa) {
    return _comensalesPorMesa[numeroMesa] ?? 0;
  }

  // Limpiar todo el estado (opcional, para reiniciar la app)
  void limpiarTodo() {
    _mesasOcupadas.clear();
    _pedidosPorMesa.clear();
    _comensalesPorMesa.clear();
    notifyListeners();
  }
}
