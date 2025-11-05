import 'package:flutter/material.dart';
import '../widgets/content_card.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({Key? key}) : super(key: key);

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> productos = [
    {'nombre': 'Laptop HP', 'precio': 850.0, 'stock': 15},
    {'nombre': 'Mouse Logitech', 'precio': 25.0, 'stock': 45},
    {'nombre': 'Teclado Mecánico', 'precio': 65.0, 'stock': 32},
    {'nombre': 'Monitor LG', 'precio': 320.0, 'stock': 8},
  ];

  void nuevoProducto() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Función crear nuevo producto')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: ContentCard(
        title: 'Catálogo de Productos',
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre, código o categoría...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: nuevoProducto,
                  icon: const Icon(Icons.add_box),
                  label: const Text('Nuevo Producto'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildProductsGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: productos.length,
      itemBuilder: (context, index) {
        var producto = productos[index];
        return _buildProductCard(
          producto['nombre'],
          "\${producto['precio']}",
          "${producto['stock']} unid.",
        );
      },
    );
  }

  Widget _buildProductCard(String name, String price, String stock) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inventory_2, size: 48, color: Color(0xFF3B82F6)),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(price, style: const TextStyle(color: Color(0xFF3B82F6))),
          const SizedBox(height: 4),
          Text(
            stock,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
        ],
      ),
    );
  }
}
