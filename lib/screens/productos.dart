import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importar Firestore
import '../widgets/content_card.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({Key? key}) : super(key: key);

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  // --- CONTROLADORES DE ESTADO Y FIREBASE ---
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Instancia de Firestore
  final TextEditingController _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Controladores para el formulario de producto (CRUD)
  final _nombreController = TextEditingController();
  final _precioController = TextEditingController();
  final _stockController = TextEditingController();

  //variable de estado para busqueda
  String _filtroBusqueda = '';

  // ID del documento si estamos editando
  String? _productoIdEnEdicion;

  @override
  void dispose() {
    _searchController.dispose();
    _nombreController.dispose();
    _precioController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  // --- FUNCIONES CRUD ---

  void _limpiarFormulario() {
    _nombreController.clear();
    _precioController.clear();
    _stockController.clear();
    _productoIdEnEdicion = null;
  }

  // C: Crear o U: Actualizar un producto
  Future<void> _guardarProducto() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final double precio = double.parse(_precioController.text);
      final int stock = int.parse(_stockController.text);

      final Map<String, dynamic> datos = {
        'nombre': _nombreController.text,
        'precio': precio,
        'stock': stock,
        'fechaActualizacion': FieldValue.serverTimestamp(),
      };

      if (_productoIdEnEdicion == null) {
        // CREAR (C)
        await _firestore.collection('platillos').add(datos);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto creado exitosamente')),
        );
      } else {
        // ACTUALIZAR (U)
        await _firestore
            .collection('platillos')
            .doc(_productoIdEnEdicion)
            .update(datos);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto actualizado exitosamente')),
        );
      }

      Navigator.of(context).pop(); // Cierra el diálogo
      _limpiarFormulario();
    } catch (e) {
      print('Error al guardar producto: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: ${e.toString()}')),
      );
    }
  }

  // D: Eliminar un producto
  Future<void> _eliminarProducto(String productId) async {
    try {
      await _firestore.collection('platillos').doc(productId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Producto eliminado'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      print('Error al eliminar producto: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: ${e.toString()}')),
      );
    }
  }

  // --- DIÁLOGOS Y NAVEGACIÓN ---

  void nuevoProducto() {
    _limpiarFormulario();
    _mostrarDialogoProducto(
      titulo: 'Nuevo Platillo',
      onGuardar: _guardarProducto,
    );
  }

  void editarProducto(DocumentSnapshot doc) {
    _productoIdEnEdicion = doc.id;
    final data = doc.data() as Map<String, dynamic>;

    // Rellenar controladores con datos existentes
    _nombreController.text = data['nombre'] ?? '';
    _precioController.text = (data['precio'] ?? 0.0).toString();
    _stockController.text = (data['stock'] ?? 0).toString();

    _mostrarDialogoProducto(
      titulo: 'Editar Platillo',
      onGuardar: _guardarProducto,
    );
  }

  void _mostrarDialogoProducto({
    required String titulo,
    required Future<void> Function() onGuardar,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(titulo),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    validator: (v) => v!.isEmpty ? 'Ingrese un nombre' : null,
                  ),
                  TextFormField(
                    controller: _precioController,
                    decoration: const InputDecoration(labelText: 'Precio'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty || double.tryParse(v) == null
                        ? 'Precio inválido'
                        : null,
                  ),
                  TextFormField(
                    controller: _stockController,
                    decoration: const InputDecoration(labelText: 'Stock'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty || int.tryParse(v) == null
                        ? 'Stock inválido'
                        : null,
                  ),
                  // Puedes añadir más campos (categoría, descripción, imagen, etc.) aquí
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(onPressed: onGuardar, child: const Text('Guardar')),
          ],
        );
      },
    );
  }

  // --- WIDGETS DE VISTA ---

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: ContentCard(
        title: 'Catálogo de Platillos',
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      //escuchador de cambios
                      setState(() {
                        _filtroBusqueda = value
                            .toLowerCase(); //convierte a minusculas
                      });
                    },
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
                  label: const Text('Nuevo Platillo'),
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
            _buildProductsGrid(), // Ahora usa StreamBuilder internamente
          ],
        ),
      ),
    );
  }

  Widget _buildProductsGrid() {
    // R: Leer productos usando StreamBuilder para obtener actualizaciones en tiempo real
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('platillos')
          .snapshots(), // Stream a la colección
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final productosDocs = snapshot.data!.docs;

        // --- LÓGICA DE FILTRADO (CLAVE) ---
        final documentosFiltrados = productosDocs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final nombreProducto = (data['nombre'] as String? ?? '')
              .toLowerCase();

          // Retorna verdadero si el nombre contiene el texto de búsqueda
          return nombreProducto.contains(_filtroBusqueda);
        }).toList();

        if (documentosFiltrados.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                _filtroBusqueda.isEmpty
                    ? 'No hay platillos registrados.'
                    : 'No se encontraron platillos con "${_searchController.text}".',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.9,
          ),
          itemCount: documentosFiltrados.length,
          itemBuilder: (context, index) {
            final doc = documentosFiltrados[index];
            final data = doc.data() as Map<String, dynamic>;

            return _buildProductCard(
              doc, // Pasamos el documento completo al Card
              data['nombre'] ?? 'Sin nombre',
              (data['precio'] ?? 0.0).toStringAsFixed(2),
              (data['stock'] ?? 0).toString(),
            );
          },
        );
      },
    );
  }

  // Modificamos el ProductCard para incluir los botones de CRUD
  Widget _buildProductCard(
    DocumentSnapshot doc,
    String name,
    String price,
    String stock,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, // Distribuir el espacio
        children: [
          // Sección de Info
          Column(
            children: [
              const Icon(
                Icons.restaurant_menu,
                size: 40,
                color: Color(0xFF3B82F6),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '\$$price',
                style: const TextStyle(
                  color: Color(0xFF3B82F6),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$stock unid.',
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
              ),
            ],
          ),

          // Sección de Acciones (Editar/Eliminar)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                color: Colors.blue,
                onPressed: () => editarProducto(doc), // Llamar a editar
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 20),
                color: Colors.red,
                onPressed: () => _eliminarProducto(doc.id), // Llamar a eliminar
              ),
            ],
          ),
        ],
      ),
    );
  }
}
