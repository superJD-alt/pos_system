class CuentaCerrada {
  final String id;
  final int numeroMesa;
  final String mesero;
  final int comensales;
  final DateTime fechaApertura;
  final DateTime fechaCierre;
  final List<Map<String, dynamic>> productos;
  final int totalItems;
  final double totalCuenta;

  CuentaCerrada({
    required this.id,
    required this.numeroMesa,
    required this.mesero,
    required this.comensales,
    required this.fechaApertura,
    required this.fechaCierre,
    required this.productos,
    required this.totalItems,
    required this.totalCuenta,
  });

  // Convertir a Map para guardar
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'numeroMesa': numeroMesa,
      'mesero': mesero,
      'comensales': comensales,
      'fechaApertura': fechaApertura.toIso8601String(),
      'fechaCierre': fechaCierre.toIso8601String(),
      'productos': productos,
      'totalItems': totalItems,
      'totalCuenta': totalCuenta,
    };
  }

  // Crear desde Map
  factory CuentaCerrada.fromMap(Map<String, dynamic> map) {
    return CuentaCerrada(
      id: map['id'] ?? '',
      numeroMesa: map['numeroMesa'] ?? 0,
      mesero: map['mesero'] ?? '',
      comensales: map['comensales'] ?? 0,
      fechaApertura: DateTime.parse(map['fechaApertura']),
      fechaCierre: DateTime.parse(map['fechaCierre']),
      productos: List<Map<String, dynamic>>.from(map['productos'] ?? []),
      totalItems: map['totalItems'] ?? 0,
      totalCuenta: (map['totalCuenta'] ?? 0.0).toDouble(),
    );
  }

  // Calcular duración de la mesa
  Duration get duracionMesa {
    return fechaCierre.difference(fechaApertura);
  }

  // Formatear duración en texto legible
  String get duracionFormateada {
    final duration = duracionMesa;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '$hours h $minutes min';
    } else {
      return '$minutes min';
    }
  }

  // Ticket promedio por comensal
  double get ticketPromedio {
    return comensales > 0 ? totalCuenta / comensales : 0.0;
  }
}
