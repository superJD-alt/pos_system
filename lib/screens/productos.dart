import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/content_card.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({Key? key}) : super(key: key);

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  // --- CONFIGURACIÓN DE CLOUDINARY ---
  final String _cloudinaryCloudName = 'dkhbeu0ry';
  final String _cloudinaryUploadPreset = 'pos_system';

  // --- CONTROLADORES DE ESTADO Y FIREBASE ---
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Controladores para el formulario de producto (CRUD)
  final _nombreController = TextEditingController();
  final _precioController = TextEditingController();

  // Variables para manejo de imágenes
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _imagenSeleccionada;
  String? _urlImagenActual;
  bool _subiendoImagen = false;

  // Variable de estado para búsqueda
  String _filtroBusqueda = '';

  // ID del documento si estamos editando
  String? _productoIdEnEdicion;

  @override
  void dispose() {
    _searchController.dispose();
    _nombreController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  // --- FUNCIONES DE IMAGEN ---

  Future<void> _seleccionarImagen() async {
    try {
      final XFile? imagen = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (imagen != null && mounted) {
        _imagenSeleccionada = imagen;
      }
    } catch (e) {
      print('Error al seleccionar imagen: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: ${e.toString()}'),
          ),
        );
      }
    }
  }

  Future<String?> _subirImagenACloudinary(XFile imagen) async {
    try {
      if (mounted) {
        setState(() => _subiendoImagen = true);
      }

      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudinaryCloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', url);
      request.fields['upload_preset'] = _cloudinaryUploadPreset;
      request.fields['folder'] = 'platillos';

      if (kIsWeb) {
        final bytes = await imagen.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes('file', bytes, filename: imagen.name),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath('file', imagen.path),
        );
      }

      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonResponse = json.decode(responseString);

      if (response.statusCode == 200) {
        return jsonResponse['secure_url'] as String;
      } else {
        print('Error de Cloudinary: $jsonResponse');
        throw Exception(
          'Error al subir imagen: ${jsonResponse['error']['message']}',
        );
      }
    } catch (e) {
      print('Error al subir imagen a Cloudinary: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir imagen: ${e.toString()}')),
        );
      }
      return null;
    } finally {
      if (mounted) {
        setState(() => _subiendoImagen = false);
      }
    }
  }

  // --- FUNCIONES CRUD ---

  void _limpiarFormulario() {
    _nombreController.clear();
    _precioController.clear();
    _productoIdEnEdicion = null;
    _imagenSeleccionada = null;
    _urlImagenActual = null;
  }

  // C: Crear o U: Actualizar un producto
  Future<void> _guardarProducto() async {
    if (!_formKey.currentState!.validate()) return;

    // Evitar múltiples llamadas simultáneas
    if (_subiendoImagen) return;

    if (mounted) {
      setState(() => _subiendoImagen = true);
    }

    try {
      final double precio = double.parse(_precioController.text);

      // Si hay una nueva imagen seleccionada, subirla a Cloudinary
      String? urlImagen = _urlImagenActual;
      if (_imagenSeleccionada != null) {
        urlImagen = await _subirImagenACloudinary(_imagenSeleccionada!);
        if (urlImagen == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al subir la imagen')),
          );
          return;
        }
      }

      final Map<String, dynamic> datos = {
        'nombre': _nombreController.text.trim(),
        'precio': precio,
        'url': urlImagen,
        'fechaActualizacion': FieldValue.serverTimestamp(),
      };

      if (_productoIdEnEdicion == null) {
        // CREAR (C)
        await _firestore.collection('platillos').add(datos);
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Producto creado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // ACTUALIZAR (U)
        await _firestore
            .collection('platillos')
            .doc(_productoIdEnEdicion)
            .update(datos);
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Producto actualizado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      _limpiarFormulario();
    } catch (e) {
      print('Error al guardar producto: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _subiendoImagen = false);
      }
    }
  }

  // D: Eliminar un producto
  Future<void> _eliminarProducto(String productId) async {
    // Confirmación antes de eliminar
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Está seguro de eliminar este producto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

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
    _urlImagenActual = data['url'];
    _imagenSeleccionada = null;

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
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(titulo),
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // SECCIÓN DE IMAGEN
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: _buildVistaPreviewImagen(),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await _seleccionarImagen();
                          // Solo actualizar el diálogo, NO el widget principal
                          setDialogState(() {});
                        },
                        icon: const Icon(Icons.image),
                        label: Text(
                          _imagenSeleccionada != null ||
                                  _urlImagenActual != null
                              ? 'Cambiar Imagen'
                              : 'Seleccionar Imagen',
                        ),
                      ),
                      const SizedBox(height: 16),

                      // CAMPOS DE TEXTO
                      TextFormField(
                        controller: _nombreController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre *',
                          prefixIcon: Icon(Icons.restaurant_menu),
                        ),
                        validator: (v) =>
                            v!.isEmpty ? 'Ingrese un nombre' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _precioController,
                        decoration: const InputDecoration(
                          labelText: 'Precio *',
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            v!.isEmpty || double.tryParse(v) == null
                            ? 'Precio inválido'
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: _subiendoImagen
                      ? null
                      : () {
                          Navigator.of(context).pop();
                          _limpiarFormulario();
                        },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: _subiendoImagen
                      ? null
                      : () async {
                          await onGuardar();
                          // Actualizar el diálogo después de guardar
                          if (mounted) {
                            setDialogState(() {});
                          }
                        },
                  child: _subiendoImagen
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text('Guardando...'),
                          ],
                        )
                      : const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildVistaPreviewImagen() {
    if (_imagenSeleccionada != null) {
      if (kIsWeb) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(_imagenSeleccionada!.path, fit: BoxFit.cover),
        );
      } else {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(File(_imagenSeleccionada!.path), fit: BoxFit.cover),
        );
      }
    }

    if (_urlImagenActual != null && _urlImagenActual!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          _urlImagenActual!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
            );
          },
        ),
      );
    }

    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey),
          SizedBox(height: 8),
          Text('Sin imagen', style: TextStyle(color: Colors.grey)),
        ],
      ),
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
                      if (mounted) {
                        setState(() {
                          _filtroBusqueda = value.toLowerCase();
                        });
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre o categoría...',
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
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    elevation: 5,
                  ),
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
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('platillos').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final productosDocs = snapshot.data!.docs;

        final documentosFiltrados = productosDocs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final nombreProducto = (data['nombre'] as String? ?? '')
              .toLowerCase();
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
            childAspectRatio: 0.7,
          ),
          itemCount: documentosFiltrados.length,
          itemBuilder: (context, index) {
            final doc = documentosFiltrados[index];
            final data = doc.data() as Map<String, dynamic>;

            return _buildProductCard(
              doc,
              data['nombre'] ?? 'Sin nombre',
              (data['precio'] ?? 0.0).toStringAsFixed(2),
              data['url'],
            );
          },
        );
      },
    );
  }

  Widget _buildProductCard(
    DocumentSnapshot doc,
    String name,
    String precio,
    String? imageUrl,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // SECCIÓN DE IMAGEN
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[100],
                          child: const Center(
                            child: Icon(
                              Icons.restaurant_menu,
                              size: 60,
                              color: Color(0xFF3B82F6),
                            ),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[100],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[100],
                      child: const Center(
                        child: Icon(
                          Icons.restaurant_menu,
                          size: 60,
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                    ),
            ),
          ),

          // SECCIÓN DE INFORMACIÓN
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre del platillo
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Precio
                    Text(
                      '\$$precio',
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Botones de Acción
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => editarProducto(doc),
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text(
                              'Editar',
                              style: TextStyle(fontSize: 11),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              side: const BorderSide(color: Colors.blue),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _eliminarProducto(doc.id),
                            icon: const Icon(Icons.delete, size: 16),
                            label: const Text(
                              'Borrar',
                              style: TextStyle(fontSize: 11),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              side: const BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
