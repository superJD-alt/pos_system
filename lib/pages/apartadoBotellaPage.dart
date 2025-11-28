import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class apartadoBotellaPage extends StatefulWidget {
  const apartadoBotellaPage({Key? key}) : super(key: key);

  @override
  State<apartadoBotellaPage> createState() => _apartadoBotellaPageState();
}

class _apartadoBotellaPageState extends State<apartadoBotellaPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final formKey = GlobalKey<FormState>();
  final ImagePicker picker = ImagePicker();

  // CONFIGURACIÓN DE CLOUDINARY
  final String cloudinaryCloudName = 'dkhbeu0ry';
  final String cloudinaryUploadPreset = 'pos_system';

  // Controladores para el formulario
  final TextEditingController imageUrlController = TextEditingController();
  final TextEditingController clientNameController = TextEditingController();
  final TextEditingController drinkTypeController = TextEditingController();
  final TextEditingController volumeController = TextEditingController();
  final TextEditingController reservationDateController =
      TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController servingsRemainingController =
      TextEditingController();

  String selectedStatus = 'en reserva';
  File? selectedImage;
  bool isUploading = false;

  @override
  void dispose() {
    imageUrlController.dispose();
    clientNameController.dispose();
    drinkTypeController.dispose();
    volumeController.dispose();
    reservationDateController.dispose();
    notesController.dispose();
    brandController.dispose();
    servingsRemainingController.dispose();
    super.dispose();
  }

  void clearForm() {
    imageUrlController.clear();
    clientNameController.clear();
    drinkTypeController.clear();
    volumeController.clear();
    reservationDateController.clear();
    notesController.clear();
    brandController.clear();
    servingsRemainingController.clear();
    selectedStatus = 'en reserva';
    selectedImage = null;
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          selectedImage = File(image.path);
        });

        // Subir automáticamente a Cloudinary
        await uploadToCloudinary();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imagen: $e')),
        );
      }
    }
  }

  Future<void> uploadToCloudinary() async {
    if (selectedImage == null) return;

    setState(() {
      isUploading = true;
    });

    try {
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudinaryCloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', url);
      request.fields['upload_preset'] = cloudinaryUploadPreset;
      request.fields['folder'] = 'botellas_apartadas';

      request.files.add(
        await http.MultipartFile.fromPath('file', selectedImage!.path),
      );

      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonMap = jsonDecode(responseString);

      if (response.statusCode == 200) {
        setState(() {
          imageUrlController.text = jsonMap['secure_url'];
          isUploading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Imagen subida exitosamente')),
          );
        }
      } else {
        throw Exception(
          'Error al subir imagen: ${jsonMap['error']['message']}',
        );
      }
    } catch (e) {
      setState(() {
        isUploading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al subir imagen: $e')));
      }
    }
  }

  void showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar imagen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFFD97706)),
              title: const Text('Cámara'),
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Color(0xFFD97706),
              ),
              title: const Text('Galería'),
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> createBottle() async {
    if (formKey.currentState!.validate()) {
      try {
        await firestore.collection('botellaApartado').add({
          'imageUrl': imageUrlController.text,
          'clientName': clientNameController.text,
          'drinkType': drinkTypeController.text,
          'volume': volumeController.text,
          'reservationDate': reservationDateController.text,
          'status': selectedStatus,
          'notes': notesController.text,
          'brand': brandController.text,
          'servingsRemaining': servingsRemainingController.text,
          'createdAt': FieldValue.serverTimestamp(),
        });
        clearForm();
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Botella agregada exitosamente')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al agregar botella: $e')),
          );
        }
      }
    }
  }

  Future<void> updateBottle(String docId) async {
    if (formKey.currentState!.validate()) {
      try {
        await firestore.collection('botellaApartado').doc(docId).update({
          'imageUrl': imageUrlController.text,
          'clientName': clientNameController.text,
          'drinkType': drinkTypeController.text,
          'volume': volumeController.text,
          'reservationDate': reservationDateController.text,
          'status': selectedStatus,
          'notes': notesController.text,
          'brand': brandController.text,
          'servingsRemaining': servingsRemainingController.text,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        clearForm();
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Botella actualizada exitosamente')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al actualizar botella: $e')),
          );
        }
      }
    }
  }

  Future<void> deleteBottle(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de eliminar esta botella?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await firestore.collection('botellaApartado').doc(docId).delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Botella eliminada exitosamente')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar botella: $e')),
          );
        }
      }
    }
  }

  void showBottleDialog({String? docId, Map<String, dynamic>? data}) {
    if (data != null) {
      imageUrlController.text = data['imageUrl'] ?? '';
      clientNameController.text = data['clientName'] ?? '';
      drinkTypeController.text = data['drinkType'] ?? '';
      volumeController.text = data['volume'] ?? '';
      reservationDateController.text = data['reservationDate'] ?? '';
      notesController.text = data['notes'] ?? '';
      brandController.text = data['brand'] ?? '';
      servingsRemainingController.text = data['servingsRemaining'] ?? '';
      selectedStatus = data['status'] ?? 'en reserva';
    } else {
      clearForm();
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFD97706),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.wine_bar, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        docId == null ? 'Nueva Botella' : 'Editar Botella',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        // Vista previa de imagen
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: selectedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    selectedImage!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : imageUrlController.text.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    imageUrlController.text,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Icon(
                                          Icons.wine_bar,
                                          size: 60,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : const Center(
                                  child: Icon(
                                    Icons.wine_bar,
                                    size: 60,
                                    color: Colors.grey,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16),

                        // Botones para imagen
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: isUploading
                                    ? null
                                    : showImageSourceDialog,
                                icon: isUploading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.upload),
                                label: Text(
                                  isUploading ? 'Subiendo...' : 'Subir Imagen',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD97706),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                            if (selectedImage != null ||
                                imageUrlController.text.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    selectedImage = null;
                                    imageUrlController.clear();
                                  });
                                },
                                icon: const Icon(Icons.delete),
                                color: Colors.red,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: clientNameController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre del Cliente *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Este campo es requerido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: brandController,
                          decoration: const InputDecoration(
                            labelText: 'Marca/Modelo *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.label),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Este campo es requerido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: drinkTypeController,
                          decoration: const InputDecoration(
                            labelText: 'Tipo de Bebida *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.local_bar),
                            hintText: 'Whisky, Tequila, Ron...',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Este campo es requerido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: volumeController,
                          decoration: const InputDecoration(
                            labelText: 'Volumen *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.straighten),
                            hintText: '750ml, 1L...',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Este campo es requerido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: reservationDateController,
                          decoration: const InputDecoration(
                            labelText: 'Fecha de Apartado *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                            hintText: 'YYYY-MM-DD',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Este campo es requerido';
                            }
                            return null;
                          },
                          onTap: () async {
                            FocusScope.of(context).requestFocus(FocusNode());
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (date != null) {
                              reservationDateController.text = DateFormat(
                                'yyyy-MM-dd',
                              ).format(date);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedStatus,
                          decoration: const InputDecoration(
                            labelText: 'Estado *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.info),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'en reserva',
                              child: Text('En Reserva'),
                            ),
                            DropdownMenuItem(
                              value: 'apartado',
                              child: Text('Apartado'),
                            ),
                            DropdownMenuItem(
                              value: 'terminado',
                              child: Text('Terminado'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedStatus = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: servingsRemainingController,
                          decoration: const InputDecoration(
                            labelText: 'Servicios Restantes *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.local_drink),
                            hintText: '10 copas, 15 onzas...',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Este campo es requerido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: notesController,
                          decoration: const InputDecoration(
                            labelText: 'Notas',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.note),
                            hintText: 'Información adicional...',
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: isUploading
                                    ? null
                                    : () {
                                        if (docId == null) {
                                          createBottle();
                                        } else {
                                          updateBottle(docId);
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD97706),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  docId == null ? 'Guardar' : 'Actualizar',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  clearForm();
                                  Navigator.pop(context);
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Cancelar',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'en reserva':
        return Colors.blue;
      case 'apartado':
        return Colors.green;
      case 'terminado':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.wine_bar, size: 28),
            SizedBox(width: 12),
            Text(
              'Botellas Apartadas',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFD97706),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.amber.shade50, Colors.orange.shade100],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: firestore.collection('botellaApartado').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final bottles = snapshot.data!.docs;

            if (bottles.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.wine_bar, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No hay botellas apartadas',
                      style: TextStyle(fontSize: 20, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Agrega la primera botella',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 900
                    ? 3
                    : MediaQuery.of(context).size.width > 600
                    ? 2
                    : 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: bottles.length,
              itemBuilder: (context, index) {
                final bottle = bottles[index].data() as Map<String, dynamic>;
                final docId = bottles[index].id;

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: Container(
                          height: 180,
                          width: double.infinity,
                          color: Colors.grey[200],
                          child:
                              bottle['imageUrl'] != null &&
                                  bottle['imageUrl'].isNotEmpty
                              ? Image.network(
                                  bottle['imageUrl'],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.wine_bar,
                                      size: 60,
                                      color: Colors.grey,
                                    );
                                  },
                                )
                              : const Icon(
                                  Icons.wine_bar,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      bottle['brand'] ?? 'Sin marca',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: getStatusColor(
                                        bottle['status'] ?? 'en reserva',
                                      ).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      bottle['status'] ?? 'en reserva',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: getStatusColor(
                                          bottle['status'] ?? 'en reserva',
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              buildInfoRow(
                                Icons.person,
                                'Cliente',
                                bottle['clientName'],
                              ),
                              const SizedBox(height: 8),
                              buildInfoRow(
                                Icons.local_bar,
                                'Tipo',
                                '${bottle['drinkType']} (${bottle['volume']})',
                              ),
                              const SizedBox(height: 8),
                              buildInfoRow(
                                Icons.calendar_today,
                                'Apartado',
                                bottle['reservationDate'],
                              ),
                              const SizedBox(height: 8),
                              buildInfoRow(
                                Icons.local_drink,
                                'Restante',
                                bottle['servingsRemaining'],
                              ),
                              if (bottle['notes'] != null &&
                                  bottle['notes'].isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    bottle['notes'],
                                    style: const TextStyle(fontSize: 11),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                              const Spacer(),
                              const Divider(),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => showBottleDialog(
                                        docId: docId,
                                        data: bottle,
                                      ),
                                      icon: const Icon(Icons.edit, size: 16),
                                      label: const Text('Editar'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => deleteBottle(docId),
                                      icon: const Icon(Icons.delete, size: 16),
                                      label: const Text('Eliminar'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showBottleDialog(),
        backgroundColor: const Color(0xFFD97706),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nueva Botella'),
      ),
    );
  }

  Widget buildInfoRow(IconData icon, String label, String? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: const Color(0xFFD97706)),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 12, color: Colors.black87),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: value ?? 'N/A'),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
