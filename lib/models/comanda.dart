// lib/models/comanda.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Comanda {
  final String id;
  final int numeroMesa;
  final String mesero;
  final int comensales;
  final DateTime fechaHora;
  final String destino; // 'cocina' o 'barra'
  final String estado; // 'pendiente', 'preparando', 'completada', 'cancelada'
  final List<Map<String, dynamic>> productos;
  final int totalProductos;
  final String? turnoId;

  Comanda({
    required this.id,
    required this.numeroMesa,
    required this.mesero,
    required this.comensales,
    required this.fechaHora,
    required this.destino,
    required this.estado,
    required this.productos,
    required this.totalProductos,
    this.turnoId,
  });

  // Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'numeroMesa': numeroMesa,
      'mesero': mesero,
      'comensales': comensales,
      'fechaHora': Timestamp.fromDate(fechaHora),
      'destino': destino,
      'estado': estado,
      'productos': productos,
      'totalProductos': totalProductos,
      'turnoId': turnoId,
    };
  }

  // Crear desde Firestore
  factory Comanda.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Comanda(
      id: data['id'] ?? doc.id,
      numeroMesa: data['numeroMesa'] ?? 0,
      mesero: data['mesero'] ?? '',
      comensales: data['comensales'] ?? 0,
      fechaHora: (data['fechaHora'] as Timestamp).toDate(),
      destino: data['destino'] ?? 'cocina',
      estado: data['estado'] ?? 'pendiente',
      productos: List<Map<String, dynamic>>.from(data['productos'] ?? []),
      totalProductos: data['totalProductos'] ?? 0,
      turnoId: data['turnoId'],
    );
  }
}
