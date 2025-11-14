import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/content_card.dart';
import '../screens/inventario_seeder.dart';

class InventarioScreen extends StatefulWidget {
  const InventarioScreen({Key? key}) : super(key: key);

  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Agregar producto
  void agregarProducto() {
    showDialog(
      context: context,
      builder: (context) => ProductoDialog(
        onSave: (producto) async {
          try {
            await _firestore.collection('inventario').add(producto);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Producto agregado exitosamente')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Error: $e')));
            }
          }
        },
      ),
    );
  }

  // Editar producto
  void editarProducto(String docId, Map<String, dynamic> productoActual) {
    showDialog(
      context: context,
      builder: (context) => ProductoDialog(
        productoActual: productoActual,
        onSave: (producto) async {
          try {
            await _firestore
                .collection('inventario')
                .doc(docId)
                .update(producto);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Producto actualizado exitosamente'),
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Error: $e')));
            }
          }
        },
      ),
    );
  }

  // Eliminar producto
  void eliminarProducto(String docId, String nombre) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Está seguro de eliminar "$nombre"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _firestore.collection('inventario').doc(docId).delete();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Producto eliminado')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
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

                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: agregarProducto,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Agregar Producto'),
                  style: ElevatedButton.styleFrom(
                    //color de fondo
                    backgroundColor:
                        Colors.blueAccent, // Usar el color principal del tema
                    foregroundColor:
                        Colors.white, // Color del texto y del icono
                    //bordes redondeados
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Radio de 10
                    ),

                    //relleno
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),

                    //sombra
                    elevation: 5,
                  ),
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
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('inventario').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        var productos = snapshot.data!.docs.where((doc) {
          if (_searchQuery.isEmpty) return true;
          var data = doc.data() as Map<String, dynamic>;
          return data['nombre'].toString().toLowerCase().contains(
                _searchQuery,
              ) ||
              data['id'].toString().toLowerCase().contains(_searchQuery) ||
              data['categoria'].toString().toLowerCase().contains(_searchQuery);
        }).toList();

        if (productos.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('No hay productos registrados'),
            ),
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Table(
            border: TableBorder.all(color: const Color(0xFFE2E8F0)),
            columnWidths: const {
              0: FixedColumnWidth(100),
              1: FixedColumnWidth(180),
              2: FixedColumnWidth(120),
              3: FixedColumnWidth(80),
              4: FixedColumnWidth(100),
              5: FixedColumnWidth(100),
              6: FixedColumnWidth(120),
              7: FixedColumnWidth(100),
              8: FixedColumnWidth(100),
              9: FixedColumnWidth(150),
              10: FixedColumnWidth(120),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
                children: [
                  _buildTableHeader('Código'),
                  _buildTableHeader('Nombre'),
                  _buildTableHeader('Categoría'),
                  _buildTableHeader('Stock'),
                  _buildTableHeader('Stock Mín'),
                  _buildTableHeader('Precio'),
                  _buildTableHeader('Unidad'),
                  _buildTableHeader('Proveedor'),
                  _buildTableHeader('Fecha Compra'),
                  _buildTableHeader('Uso Principal'),
                  _buildTableHeader('Acciones'),
                ],
              ),
              ...productos.map((doc) {
                var producto = doc.data() as Map<String, dynamic>;
                return TableRow(
                  children: [
                    _buildTableCell(producto['id'] ?? ''),
                    _buildTableCell(producto['nombre'] ?? ''),
                    _buildTableCell(producto['categoria'] ?? ''),
                    _buildTableCell(producto['stock']?.toString() ?? '0'),
                    _buildTableCell(
                      producto['stock_minimo']?.toString() ?? '0',
                    ),
                    _buildTableCell('\$${producto['precio_unitario'] ?? 0}'),
                    _buildTableCell(producto['unidad_medida'] ?? ''),
                    _buildTableCell(producto['proveedor'] ?? ''),
                    _buildTableCell(producto['fecha_compra'] ?? ''),
                    _buildTableCell(producto['uso_principal'] ?? ''),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () => editarProducto(doc.id, producto),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              size: 20,
                              color: Colors.red,
                            ),
                            onPressed: () => eliminarProducto(
                              doc.id,
                              producto['nombre'] ?? '',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ],
          ),
        );
      },
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

// Dialog para agregar/editar productos
class ProductoDialog extends StatefulWidget {
  final Map<String, dynamic>? productoActual;
  final Function(Map<String, dynamic>) onSave;

  const ProductoDialog({Key? key, this.productoActual, required this.onSave})
    : super(key: key);

  @override
  State<ProductoDialog> createState() => _ProductoDialogState();
}

class _ProductoDialogState extends State<ProductoDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _idController;
  late TextEditingController _nombreController;
  late TextEditingController _categoriaController;
  late TextEditingController _stockController;
  late TextEditingController _stockMinimoController;
  late TextEditingController _precioController;
  late TextEditingController _unidadMedidaController;
  late TextEditingController _proveedorController;
  late TextEditingController _fechaCompraController;
  late TextEditingController _usoPrincipalController;

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(
      text: widget.productoActual?['id'] ?? '',
    );
    _nombreController = TextEditingController(
      text: widget.productoActual?['nombre'] ?? '',
    );
    _categoriaController = TextEditingController(
      text: widget.productoActual?['categoria'] ?? '',
    );
    _stockController = TextEditingController(
      text: widget.productoActual?['stock']?.toString() ?? '0',
    );
    _stockMinimoController = TextEditingController(
      text: widget.productoActual?['stock_minimo']?.toString() ?? '0',
    );
    _precioController = TextEditingController(
      text: widget.productoActual?['precio_unitario']?.toString() ?? '0',
    );
    _unidadMedidaController = TextEditingController(
      text: widget.productoActual?['unidad_medida'] ?? '',
    );
    _proveedorController = TextEditingController(
      text: widget.productoActual?['proveedor'] ?? '',
    );
    _fechaCompraController = TextEditingController(
      text: widget.productoActual?['fecha_compra'] ?? '',
    );
    _usoPrincipalController = TextEditingController(
      text: widget.productoActual?['uso_principal'] ?? '',
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    _nombreController.dispose();
    _categoriaController.dispose();
    _stockController.dispose();
    _stockMinimoController.dispose();
    _precioController.dispose();
    _unidadMedidaController.dispose();
    _proveedorController.dispose();
    _fechaCompraController.dispose();
    _usoPrincipalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.productoActual == null ? 'Agregar Producto' : 'Editar Producto',
      ),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _idController,
                        decoration: const InputDecoration(
                          labelText: 'Código *',
                        ),
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Campo requerido' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _categoriaController,
                        decoration: const InputDecoration(
                          labelText: 'Categoría *',
                        ),
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Campo requerido' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre *'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _stockController,
                        decoration: const InputDecoration(labelText: 'Stock *'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Campo requerido';
                          if (int.tryParse(value!) == null)
                            return 'Debe ser un número';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _stockMinimoController,
                        decoration: const InputDecoration(
                          labelText: 'Stock Mínimo *',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Campo requerido';
                          if (int.tryParse(value!) == null)
                            return 'Debe ser un número';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _precioController,
                        decoration: const InputDecoration(
                          labelText: 'Precio Unitario *',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Campo requerido';
                          if (double.tryParse(value!) == null)
                            return 'Debe ser un número';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _unidadMedidaController,
                        decoration: const InputDecoration(
                          labelText: 'Unidad de Medida *',
                        ),
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Campo requerido' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _proveedorController,
                  decoration: const InputDecoration(labelText: 'Proveedor *'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _fechaCompraController,
                  decoration: const InputDecoration(
                    labelText: 'Fecha de Compra (AAAA-MM-DD)',
                    hintText: '2025-01-01',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _usoPrincipalController,
                  decoration: const InputDecoration(labelText: 'Uso Principal'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave({
                'id': _idController.text,
                'nombre': _nombreController.text,
                'categoria': _categoriaController.text,
                'stock': int.parse(_stockController.text),
                'stock_minimo': int.parse(_stockMinimoController.text),
                'precio_unitario': double.parse(_precioController.text),
                'unidad_medida': _unidadMedidaController.text,
                'proveedor': _proveedorController.text,
                'fecha_compra': _fechaCompraController.text,
                'uso_principal': _usoPrincipalController.text,
              });
              Navigator.pop(context);
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
