import 'package:flutter/material.dart';
import '../widgets/content_card.dart';

class ReportesScreen extends StatelessWidget {
  const ReportesScreen({Key? key}) : super(key: key);

  void descargarReporte(BuildContext context, String nombreReporte) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Descargando $nombreReporte...')));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildReportCard('Ventas Mensuales', '\$45,230', '+12%'),
              ),
              const SizedBox(width: 16),
              Expanded(child: _buildReportCard('Ganancias', '\$18,920', '+8%')),
              const SizedBox(width: 16),
              Expanded(
                child: _buildReportCard('Transacciones', '1,456', '+23%'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ContentCard(
            title: 'Reportes Disponibles',
            child: Column(
              children: [
                _buildReportItem(context, 'Reporte de Ventas Diarias'),
                _buildReportItem(context, 'Reporte de Inventario'),
                _buildReportItem(context, 'Reporte de Clientes'),
                _buildReportItem(context, 'Reporte Financiero'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(String title, String value, String change) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF64748B))),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(change, style: const TextStyle(color: Colors.green)),
        ],
      ),
    );
  }

  Widget _buildReportItem(BuildContext context, String title) {
    return ListTile(
      leading: const Icon(Icons.description, color: Color(0xFF3B82F6)),
      title: Text(title),
      trailing: ElevatedButton(
        onPressed: () => descargarReporte(context, title),
        child: const Text('Descargar'),
      ),
    );
  }
}
