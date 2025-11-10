// IMPORTANTE: Eliminamos 'dart:io'.
import 'dart:convert';
import 'dart:async'; // Necesario para 'Future'
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart'; // Para MediaType

// ===================================================================
// ⚠️ 1. CONFIGURACIÓN CLOUDINARY - ¡REEMPLAZA ESTOS VALORES!
// ===================================================================
const String CLOUDINARY_CLOUD_NAME = 'dkhbeu0ry';
const String CLOUDINARY_UPLOAD_PRESET = 'pos_system';

// ===================================================================
// 2. FUNCIONES ASÍNCRONAS - ¡AHORA WEB-COMPATIBLES!
// ===================================================================

/// Abre la galería y permite al usuario seleccionar una imagen.
/// En la web, ImagePicker devuelve XFile, que contiene los bytes.
Future<XFile?> selectProductImage() async {
  final ImagePicker picker = ImagePicker();
  try {
    // XFile ya contiene los datos de la imagen en memoria,
    // lo cual es esencial para la web.
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );
    return pickedFile;
  } catch (e) {
    // Usamos debugPrint en lugar de print para mejor manejo en Flutter
    debugPrint('Error al seleccionar la imagen: $e');
    return null;
  }
}

/// Sube un archivo de imagen a Cloudinary usando los bytes del archivo (XFile).
Future<String?> uploadImageToCloudinary(XFile pickedFile) async {
  final url = Uri.parse(
    'https://api.cloudinary.com/v1_1/$CLOUDINARY_CLOUD_NAME/image/upload',
  );

  try {
    // 1. Leer los bytes del archivo XFile (esto es web-compatible)
    final fileBytes = await pickedFile.readAsBytes();
    final fileName = pickedFile.name;

    var request = http.MultipartRequest('POST', url);
    request.fields['upload_preset'] = CLOUDINARY_UPLOAD_PRESET;

    // 2. Obtener el tipo MIME usando el nombre del archivo
    // Si no se encuentra, usa un valor por defecto (imagen/jpeg)
    final mimeType = lookupMimeType(fileName) ?? 'image/jpeg';

    // 3. Adjuntar el archivo usando fromBytes, NO fromPath.
    // Esto es lo que soluciona el error en la web.
    request.files.add(
      http.MultipartFile.fromBytes(
        'file', // Campo clave en la API de Cloudinary
        fileBytes,
        contentType: MediaType.parse(mimeType),
        filename: fileName,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final String secureUrl = data['secure_url'];
      debugPrint('✅ Imagen subida con éxito. URL: $secureUrl');
      return secureUrl;
    } else {
      debugPrint('❌ Falló la subida a Cloudinary: ${response.statusCode}');
      debugPrint('Respuesta del cuerpo: ${response.body}');
      return null;
    }
  } catch (e) {
    debugPrint('❌ Error general al subir la imagen: $e');
    return null;
  }
}

// ⚠️ FUNCIÓN DE BASE DE DATOS - REEMPLAZAR POR TU LÓGICA REAL
Future<void> saveProductImageUrl(String productId, String imageUrl) async {
  // Simulación: aquí iría tu lógica real de Firestore/otra DB
  /*
  await FirebaseFirestore.instance.collection('productos').doc(productId).update({
    'url_imagen': imageUrl,
    'ultima_actualizacion': FieldValue.serverTimestamp(),
  });
  */
  debugPrint(
    '✅ [SIMULACIÓN] URL guardada en la base de datos para ID $productId: $imageUrl',
  );
}

// ===================================================================
// 3. WIDGET DE PRUEBA (UI)
// ===================================================================

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Cloudinary Web Uploader',
      home: CloudinaryTestScreen(productId: 'prod_12345'),
    );
  }
}

class CloudinaryTestScreen extends StatefulWidget {
  final String productId;
  const CloudinaryTestScreen({required this.productId, super.key});

  @override
  State<CloudinaryTestScreen> createState() => _CloudinaryTestScreenState();
}

class _CloudinaryTestScreenState extends State<CloudinaryTestScreen> {
  String _uploadStatus = 'Pulsa el botón para seleccionar una imagen.';
  String? _imageUrl;
  bool _isLoading = false;

  void _runUploadProcess() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _uploadStatus = 'Seleccionando imagen...';
      _imageUrl = null;
    });

    // 1. Selecciona la imagen y obtén el XFile
    final XFile? pickedFile = await selectProductImage();

    if (pickedFile != null) {
      setState(
        () => _uploadStatus =
            'Subiendo a Cloudinary (ID: ${widget.productId}), espera...',
      );

      // 2. Sube la imagen usando el XFile (que es web-compatible)
      final String? url = await uploadImageToCloudinary(pickedFile);

      if (url != null) {
        await saveProductImageUrl(widget.productId, url);

        setState(() {
          _imageUrl = url;
          _uploadStatus = '¡Prueba COMPLETA! URL guardada.';
          _isLoading = false;
        });
      } else {
        setState(() {
          _uploadStatus =
              '❌ ERROR: Falló la subida a Cloudinary. Revisa la consola.';
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _uploadStatus = 'Selección de imagen cancelada.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prueba de Carga Cloudinary (Web-Compatible)'),
        backgroundColor: Colors.indigo,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Muestra el estado
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _uploadStatus,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: _uploadStatus.startsWith('❌')
                          ? Colors.red
                          : Colors.black87,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(color: Colors.indigo),
                )
              else
                ElevatedButton.icon(
                  onPressed: _runUploadProcess,
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('Cargar Imagen de Producto'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),

              const SizedBox(height: 40),

              // Muestra la imagen y la URL
              if (_imageUrl != null) ...[
                const Text(
                  'Imagen Cargada:',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 15),
                // Muestra la imagen desde la URL de Cloudinary
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      _imageUrl!,
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 150),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'URL de Cloudinary (para guardar en DB):',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SelectableText(
                  _imageUrl!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
