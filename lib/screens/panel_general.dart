import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pos_system/widgets/stat_card.dart';
import 'package:pos_system/widgets/content_card.dart';

class PanelGeneralScreen extends StatefulWidget {
  const PanelGeneralScreen({Key? key}) : super(key: key);

  @override
  State<PanelGeneralScreen> createState() => _PanelGeneralScreenState();
}

class _PanelGeneralScreenState extends State<PanelGeneralScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Calcular ventas del día actual desde movimientos de caja
  Stream<double> _getVentasHoy() {
    final DateTime ahora = DateTime.now();
    final DateTime inicioDia = DateTime(ahora.year, ahora.month, ahora.day);
    final DateTime finDia = inicioDia.add(const Duration(days: 1));

    return _firestore
        .collection('movimientos_caja')
        .where('tipo', isEqualTo: 'ingreso')
        .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(inicioDia))
        .where('fecha', isLessThan: Timestamp.fromDate(finDia))
        .snapshots()
        .map((snapshot) {
          double total = 0;
          for (var doc in snapshot.docs) {
            final data = doc.data();
            // Solo contar ventas (no otros ingresos)
            final categoria = data['categoria'] as String?;
            if (categoria != null &&
                (categoria.startsWith('venta_') || categoria == 'propinas')) {
              total += (data['monto'] as num?)?.toDouble() ?? 0.0;
            }
          }
          return total;
        });
  }

  // Contar total de productos
  Stream<int> _getTotalProductos() {
    return _firestore.collection('platillos').snapshots().map((snapshot) {
      return snapshot.docs.length;
    });
  }

  // Contar órdenes del día (movimientos de tipo ingreso con categoría de venta)
  Stream<int> _getOrdenesHoy() {
    final DateTime ahora = DateTime.now();
    final DateTime inicioDia = DateTime(ahora.year, ahora.month, ahora.day);
    final DateTime finDia = inicioDia.add(const Duration(days: 1));

    return _firestore
        .collection('movimientos_caja')
        .where('tipo', isEqualTo: 'ingreso')
        .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(inicioDia))
        .where('fecha', isLessThan: Timestamp.fromDate(finDia))
        .snapshots()
        .map((snapshot) {
          // Contar solo ventas (no otros ingresos como propinas solas)
          return snapshot.docs.where((doc) {
            final categoria = doc.data()['categoria'] as String?;
            return categoria != null && categoria.startsWith('venta_');
          }).length;
        });
  }

  // Obtener productos más vendidos (esto requeriría una colección adicional de ventas detalladas)
  // Por ahora, mostramos categorías de ventas más frecuentes
  Stream<List<Map<String, dynamic>>> _getCategoriasPopulares() {
    final DateTime ahora = DateTime.now();
    final DateTime hace30Dias = ahora.subtract(const Duration(days: 30));

    return _firestore
        .collection('movimientos_caja')
        .where('tipo', isEqualTo: 'ingreso')
        .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(hace30Dias))
        .snapshots()
        .map((snapshot) {
          // Contar ventas por categoría
          Map<String, int> conteos = {};
          Map<String, double> montos = {};

          for (var doc in snapshot.docs) {
            final data = doc.data();
            final categoria = data['categoria'] as String?;
            final monto = (data['monto'] as num?)?.toDouble() ?? 0.0;

            if (categoria != null && categoria.startsWith('venta_')) {
              conteos[categoria] = (conteos[categoria] ?? 0) + 1;
              montos[categoria] = (montos[categoria] ?? 0.0) + monto;
            }
          }

          // Convertir a lista y ordenar por cantidad de ventas
          List<Map<String, dynamic>> resultado = [];
          conteos.forEach((categoria, cantidad) {
            resultado.add({
              'categoria': categoria,
              'cantidad': cantidad,
              'monto': montos[categoria] ?? 0.0,
            });
          });

          resultado.sort(
            (a, b) => (b['cantidad'] as int).compareTo(a['cantidad'] as int),
          );
          return resultado.take(4).toList();
        });
  }

  String _formatearCategoria(String categoria) {
    switch (categoria) {
      case 'venta_efectivo':
        return 'Ventas en Efectivo';
      case 'venta_tarjeta':
        return 'Ventas con Tarjeta';
      case 'venta_transferencia':
        return 'Ventas por Transferencia';
      default:
        return categoria.replaceAll('_', ' ').toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          // Stats Cards
          Row(
            children: [
              Expanded(
                child: StreamBuilder<double>(
                  stream: _getVentasHoy(),
                  builder: (context, snapshot) {
                    final ventas = snapshot.data ?? 0.0;
                    return StatCard(
                      title: 'Ventas Hoy',
                      value: '\$${ventas.toStringAsFixed(2)}',
                      icon: Icons.trending_up,
                      color: Colors.green,
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StreamBuilder<int>(
                  stream: _getTotalProductos(),
                  builder: (context, snapshot) {
                    final productos = snapshot.data ?? 0;
                    return StatCard(
                      title: 'Productos',
                      value: '$productos',
                      icon: Icons.inventory_2,
                      color: Colors.blue,
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  title: 'Clientes',
                  value: '-',
                  icon: Icons.people,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StreamBuilder<int>(
                  stream: _getOrdenesHoy(),
                  builder: (context, snapshot) {
                    final ordenes = snapshot.data ?? 0;
                    return StatCard(
                      title: 'Órdenes',
                      value: '$ordenes',
                      icon: Icons.shopping_cart,
                      color: Colors.orange,
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Charts Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: ContentCard(
                  title: 'Ventas Recientes',
                  child: _buildVentasRecientes(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ContentCard(
                  title: 'Métodos de Pago Populares',
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _getCategoriasPopulares(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text(
                              'No hay datos disponibles',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: snapshot.data!.map((item) {
                          return _buildProductItem(
                            _formatearCategoria(item['categoria']),
                            item['cantidad'],
                            item['monto'],
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVentasRecientes() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('movimientos_caja')
          .where('tipo', isEqualTo: 'ingreso')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 300,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return SizedBox(
            height: 300,
            child: Center(
              child: Text(
                'Error al cargar datos',
                style: TextStyle(color: Colors.red[600]),
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox(
            height: 300,
            child: Center(
              child: Text(
                'No hay ventas registradas',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        // Ordenar por fecha (más reciente primero)
        final docs = snapshot.data!.docs.toList();
        docs.sort((a, b) {
          final fechaA =
              (a.data() as Map<String, dynamic>)['fecha'] as Timestamp?;
          final fechaB =
              (b.data() as Map<String, dynamic>)['fecha'] as Timestamp?;

          if (fechaA == null && fechaB == null) return 0;
          if (fechaA == null) return 1;
          if (fechaB == null) return -1;

          return fechaB.compareTo(fechaA);
        });

        // Tomar solo las 10 más recientes
        final ventasRecientes = docs.take(10).toList();

        return SizedBox(
          height: 300,
          child: ListView.builder(
            itemCount: ventasRecientes.length,
            itemBuilder: (context, index) {
              final doc = ventasRecientes[index];
              final data = doc.data() as Map<String, dynamic>;
              final categoria = data['categoria'] ?? '';
              final monto = (data['monto'] as num?)?.toDouble() ?? 0.0;
              final descripcion = data['descripcion'] ?? '';
              final fecha = data['fecha'] as Timestamp?;
              final cajero = data['cajero'] ?? 'Desconocido';

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 1,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.shade100,
                    child: const Icon(
                      Icons.attach_money,
                      color: Colors.green,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    _formatearCategoria(categoria),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (descripcion.isNotEmpty)
                        Text(
                          descripcion,
                          style: const TextStyle(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      Text(
                        'Cajero: $cajero',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                      if (fecha != null)
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(fecha.toDate()),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Text(
                      '\$${monto.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProductItem(String name, int cantidad, double monto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Chip(
                    label: Text('$cantidad ventas'),
                    backgroundColor: const Color(0xFFEFF6FF),
                    labelStyle: const TextStyle(fontSize: 11),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${monto.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 16),
        ],
      ),
    );
  }
}
