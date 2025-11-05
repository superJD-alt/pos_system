import 'package:flutter/material.dart';
import 'package:pos_system/widgets/content_card.dart';

class CajaScreen extends StatefulWidget {
  const CajaScreen({Key? key}) : super(key: key);

  @override
  State<CajaScreen> createState() => _CajaScreenState();
}

class _CajaScreenState extends State<CajaScreen> {
  double cajaInicial = 5000.0;
  double ingresos = 12450.0;
  double egresos = 2300.0;
  bool cajaAbierta = true;

  double get saldoActual => cajaInicial + ingresos - egresos;

  void abrirCaja() {
    // Aquí puedes agregar lógica para abrir caja
    setState(() {
      cajaAbierta = true;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Caja abierta exitosamente')));
  }

  void cerrarCaja() {
    // Aquí puedes agregar lógica para cerrar caja
    setState(() {
      cajaAbierta = false;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Caja cerrada exitosamente')));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: ContentCard(
        title: 'Gestión de Caja',
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    'Caja Inicial',
                    '\$${cajaInicial.toStringAsFixed(2)}',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoCard(
                    'Ingresos',
                    '\$${ingresos.toStringAsFixed(2)}',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoCard(
                    'Egresos',
                    '\$${egresos.toStringAsFixed(2)}',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoCard(
                    'Saldo Actual',
                    '\$${saldoActual.toStringAsFixed(2)}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: cajaAbierta ? null : abrirCaja,
                  icon: const Icon(Icons.add),
                  label: const Text('Abrir Caja'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: cajaAbierta ? cerrarCaja : null,
                  icon: const Icon(Icons.close),
                  label: const Text('Cerrar Caja'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Estado: ${cajaAbierta ? "Caja Abierta" : "Caja Cerrada"}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: cajaAbierta ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}
