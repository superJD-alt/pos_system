class Producto {
  final String id;
  final String nombre;
  final double precio;
  final String categoria;
  final bool disponible;
  final int? gramos;
  final String? tipo;

  Producto({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.categoria,
    required this.disponible,
    this.gramos,
    this.tipo,
  });

  // Crear desde Firestore
  factory Producto.fromFirestore(String id, Map<String, dynamic> data) {
    return Producto(
      id: id,
      nombre: data['nombre'] ?? '',
      precio: (data['precio'] ?? 0).toDouble(),
      categoria: data['categoria'] ?? '',
      disponible: data['disponible'] ?? true,
      gramos: data['gramos'],
      tipo: data['tipo'],
    );
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'precio': precio,
      'categoria': categoria,
      'disponible': disponible,
      if (gramos != null) 'gramos': gramos,
    };
  }
}
