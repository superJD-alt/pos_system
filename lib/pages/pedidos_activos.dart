import 'package:flutter/material.dart';
import 'package:pos_system/pages/mesa_state.dart';

class PedidosActivosPage extends StatefulWidget {
  const PedidosActivosPage({super.key});

  @override
  State<PedidosActivosPage> createState() => _PedidosActivosPageState();
}

class _PedidosActivosPageState extends State<PedidosActivosPage> {
  final mesaState = MesaState(); // Tu singleton

  @override
  Widget build(BuildContext context) {
    // ✅ Usamos el getter público (que debes agregar a MesaState)
    final mesasOcupadas = mesaState.obtenerMesasOcupadas();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos Activos'),
        backgroundColor: Colors.deepOrange,
      ),
      body: mesasOcupadas.isEmpty
          ? const Center(child: Text('No hay mesas con pedidos activos'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: mesasOcupadas.length,
              itemBuilder: (context, index) {
                final numeroMesa = mesasOcupadas[index];
                final pedidos = mesaState.obtenerPedidosEnviados(numeroMesa);
                final comensales = mesaState.obtenerComensales(numeroMesa);

                if (pedidos.isEmpty) {
                  return const SizedBox.shrink();
                }

                // Tomamos el último pedido como el más reciente
                final pedido = pedidos.last;
                final mesero = pedido["mesero"] ?? "Sin asignar";
                final fecha =
                    DateTime.tryParse(pedido["fecha"] ?? "") ?? DateTime.now();
                final alimentos = pedido["alimentos"] ?? [];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mesa $numeroMesa',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('Mesero: $mesero'),
                        Text('Comensales: $comensales'),
                        Text(
                          'Fecha: ${fecha.day}/${fecha.month}/${fecha.year} '
                          '${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}',
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Alimentos:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(alimentos.length, (i) {
                            final item = alimentos[i];
                            return Text(
                              '• ${item["nombre"]} x${item["cantidad"]}',
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
