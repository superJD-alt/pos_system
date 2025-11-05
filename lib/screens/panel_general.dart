import 'package:flutter/material.dart';
import 'package:pos_system/widgets/stat_card.dart';
import 'package:pos_system/widgets/content_card.dart';

class PanelGeneralScreen extends StatelessWidget {
  const PanelGeneralScreen({Key? key}) : super(key: key);

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
                child: StatCard(
                  title: 'Ventas Hoy',
                  value: '\$12,450',
                  icon: Icons.trending_up,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  title: 'Productos',
                  value: '248',
                  icon: Icons.inventory_2,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  title: 'Clientes',
                  value: '1,234',
                  icon: Icons.people,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  title: 'Órdenes',
                  value: '89',
                  icon: Icons.shopping_cart,
                  color: Colors.orange,
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
                  child: SizedBox(
                    height: 300,
                    child: Center(
                      child: Text(
                        'Aquí puedes agregar un gráfico de ventas',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ContentCard(
                  title: 'Productos Populares',
                  child: Column(
                    children: [
                      _buildProductItem('Laptop HP', 45),
                      _buildProductItem('Mouse Logitech', 32),
                      _buildProductItem('Teclado Mecánico', 28),
                      _buildProductItem('Monitor LG', 21),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(String name, int sales) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name),
          Chip(
            label: Text('$sales ventas'),
            backgroundColor: const Color(0xFFEFF6FF),
          ),
        ],
      ),
    );
  }
}
