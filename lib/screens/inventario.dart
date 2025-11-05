import 'package:flutter/material.dart';
import '../widgets/content_card.dart';

class InventarioScreen extends StatefulWidget {
  const InventarioScreen({Key? key}) : super(key: key);

  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Lista de productos (puedes mover esto a un modelo/servicio más adelante)
  final List<Map<String, dynamic>> productos = [
    {
      'codigo': '001',
      'nombre': 'Laptop HP',
      'categoria': 'Electrónica',
      'stock': 15,
      'precio': 850.0,
    },
    {
      'codigo': '002',
      'nombre': 'Mouse Logitech',
      'categoria': 'Accesorios',
      'stock': 45,
      'precio': 25.0,
    },
    {
      'codigo': '003',
      'nombre': 'Teclado Mecánico',
      'categoria': 'Accesorios',
      'stock': 32,
      'precio': 65.0,
    },
    {
      'codigo': '004',
      'nombre': 'Monitor LG',
      'categoria': 'Electrónica',
      'stock': 8,
      'precio': 320.0,
    },
  ];

  void agregarProducto() {
    // Lógica para agregar producto
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Función agregar producto')));
  }

  void editarProducto(int index) {
    // Lógica para editar producto
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editar ${productos[index]['nombre']}')),
    );
  }

  void eliminarProducto(int index) {
    setState(() {
      productos.removeAt(index);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Producto eliminado')));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: ContentCard(
        title: 'Control de Inventario',
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar producto...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: agregarProducto,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar Producto'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildDataTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    return Table(
      border: TableBorder.all(color: const Color(0xFFE2E8F0)),
      children: [
        TableRow(
          decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
          children: [
            _buildTableHeader('Código'),
            _buildTableHeader('Producto'),
            _buildTableHeader('Categoría'),
            _buildTableHeader('Stock'),
            _buildTableHeader('Precio'),
            _buildTableHeader('Acciones'),
          ],
        ),
        ...productos.asMap().entries.map((entry) {
          int index = entry.key;
          var producto = entry.value;
          return TableRow(
            children: [
              _buildTableCell(producto['codigo']),
              _buildTableCell(producto['nombre']),
              _buildTableCell(producto['categoria']),
              _buildTableCell(producto['stock'].toString()),
              _buildTableCell('\$${producto['precio']}'),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => editarProducto(index),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        size: 20,
                        color: Colors.red,
                      ),
                      onPressed: () => eliminarProducto(index),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(padding: const EdgeInsets.all(12), child: Text(text));
  }
}
