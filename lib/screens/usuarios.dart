import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../widgets/content_card.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({Key? key}) : super(key: key);

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  FirebaseFirestore? _firestore;
  FirebaseFunctions? _functions;
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _rolSeleccionado = 'Cajero';
  String _estadoSeleccionado = 'Activo';
  bool _isFirebaseInitialized = false;
  bool _isEditMode = false;
  String? _userIdEnEdicion;

  final List<String> rolesDisponibles = [
    'Administrador',
    'Cajero',
    'Mesero',
    'Cocinero',
  ];

  final List<String> estadosDisponibles = ['Activo', 'Inactivo'];

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      _firestore = FirebaseFirestore.instance;
      _functions = FirebaseFunctions.instance;
      setState(() {
        _isFirebaseInitialized = true;
      });
    } catch (e) {
      print('Error inicializando Firebase: $e');
      setState(() {
        _isFirebaseInitialized = false;
      });
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _limpiarFormulario() {
    _nombreController.clear();
    _emailController.clear();
    _passwordController.clear();
    _rolSeleccionado = 'Cajero';
    _estadoSeleccionado = 'Activo';
    _isEditMode = false;
    _userIdEnEdicion = null;
  }

  // ✅ CREAR USUARIO CON CLOUD FUNCTION
  Future<void> _crearUsuario() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      _mostrarCargando(context);

      final callable = _functions!.httpsCallable('crearUsuario');
      final result = await callable.call({
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'nombre': _nombreController.text.trim(),
        'rol': _rolSeleccionado,
        'estado': _estadoSeleccionado,
        'sesionActiva': false, // ✅ Inicializar sesión como inactiva
      });

      Navigator.of(context).pop(); // Cerrar loading
      Navigator.of(context).pop(); // Cerrar diálogo

      if (result.data['success']) {
        _mostrarSnackBar('Usuario creado exitosamente', Colors.green);
        _limpiarFormulario();
      }
    } on FirebaseFunctionsException catch (e) {
      Navigator.of(context).pop(); // Cerrar loading
      _mostrarSnackBar('Error: ${e.message}', Colors.red);
    } catch (e) {
      Navigator.of(context).pop(); // Cerrar loading
      _mostrarSnackBar('Error inesperado: $e', Colors.red);
    }
  }

  // ✅ ACTUALIZAR USUARIO CON CLOUD FUNCTION
  Future<void> _actualizarUsuario() async {
    if (!_formKey.currentState!.validate() || _userIdEnEdicion == null) return;

    try {
      _mostrarCargando(context);

      // Actualizar datos básicos
      final callableUpdate = _functions!.httpsCallable('actualizarUsuario');
      await callableUpdate.call({
        'userId': _userIdEnEdicion,
        'nombre': _nombreController.text.trim(),
        'rol': _rolSeleccionado,
        'estado': _estadoSeleccionado,
      });

      // Si el email cambió, actualizarlo
      final docSnapshot = await _firestore!
          .collection('usuarios')
          .doc(_userIdEnEdicion)
          .get();
      final emailActual = docSnapshot.data()?['email'] ?? '';

      if (emailActual != _emailController.text.trim()) {
        final callableEmail = _functions!.httpsCallable('actualizarEmail');
        await callableEmail.call({
          'userId': _userIdEnEdicion,
          'nuevoEmail': _emailController.text.trim(),
        });
      }

      // Si hay nueva contraseña, actualizarla
      if (_passwordController.text.isNotEmpty) {
        final callablePassword = _functions!.httpsCallable(
          'actualizarPassword',
        );
        await callablePassword.call({
          'userId': _userIdEnEdicion,
          'nuevaPassword': _passwordController.text,
        });
      }

      Navigator.of(context).pop(); // Cerrar loading
      Navigator.of(context).pop(); // Cerrar diálogo

      _mostrarSnackBar('Usuario actualizado exitosamente', Colors.blue);
      _limpiarFormulario();
    } on FirebaseFunctionsException catch (e) {
      Navigator.of(context).pop(); // Cerrar loading
      _mostrarSnackBar('Error: ${e.message}', Colors.red);
    } catch (e) {
      Navigator.of(context).pop(); // Cerrar loading
      _mostrarSnackBar('Error inesperado: $e', Colors.red);
    }
  }

  // ✅ ELIMINAR USUARIO CON CLOUD FUNCTION
  Future<void> _eliminarUsuario(String userId, String nombre) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('¿Está seguro de eliminar a $nombre?'),
              const SizedBox(height: 8),
              const Text(
                '⚠️ Esta acción eliminará al usuario de Authentication y Firestore',
                style: TextStyle(fontSize: 12, color: Colors.orange),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Cerrar diálogo de confirmación

                try {
                  _mostrarCargando(context);

                  final callable = _functions!.httpsCallable('eliminarUsuario');
                  final result = await callable.call({'userId': userId});

                  Navigator.of(context).pop(); // Cerrar loading

                  if (result.data['success']) {
                    _mostrarSnackBar('Usuario eliminado', Colors.red);
                  }
                } on FirebaseFunctionsException catch (e) {
                  Navigator.of(context).pop(); // Cerrar loading
                  _mostrarSnackBar('Error: ${e.message}', Colors.red);
                } catch (e) {
                  Navigator.of(context).pop(); // Cerrar loading
                  _mostrarSnackBar('Error inesperado: $e', Colors.red);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void nuevoUsuario() {
    _limpiarFormulario();
    _isEditMode = false;
    _mostrarDialogoUsuario(titulo: 'Nuevo Usuario', onGuardar: _crearUsuario);
  }

  void editarUsuario(String userId, Map<String, dynamic> usuario) {
    _isEditMode = true;
    _userIdEnEdicion = userId;
    _nombreController.text = usuario['nombre'] ?? '';
    _emailController.text = usuario['email'] ?? '';

    _rolSeleccionado = rolesDisponibles.contains(usuario['rol'])
        ? usuario['rol']
        : 'Cajero';

    _estadoSeleccionado = estadosDisponibles.contains(usuario['estado'])
        ? usuario['estado']
        : 'Activo';

    _mostrarDialogoUsuario(
      titulo: 'Editar Usuario',
      onGuardar: _actualizarUsuario,
    );
  }

  void _mostrarDialogoUsuario({
    required String titulo,
    required Future<void> Function() onGuardar,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                      // Campo Nombre
                      TextFormField(
                        controller: _nombreController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre completo',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor ingrese el nombre';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Campo Email
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor ingrese el email';
                          }
                          if (!value.contains('@')) {
                            return 'Por favor ingrese un email válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Campo Contraseña
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: _isEditMode
                              ? 'Nueva contraseña (opcional)'
                              : 'Contraseña',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock),
                          helperText: _isEditMode
                              ? 'Dejar en blanco para no cambiar'
                              : null,
                        ),
                        obscureText: true,
                        validator: (value) {
                          // Solo validar si NO estamos editando o si hay texto
                          if (!_isEditMode &&
                              (value == null || value.isEmpty)) {
                            return 'Por favor ingrese la contraseña';
                          }
                          if (value != null &&
                              value.isNotEmpty &&
                              value.length < 6) {
                            return 'La contraseña debe tener al menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Dropdown Rol
                      DropdownButtonFormField<String>(
                        value: _rolSeleccionado,
                        decoration: const InputDecoration(
                          labelText: 'Rol',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.badge),
                        ),
                        items: rolesDisponibles
                            .map(
                              (rol) => DropdownMenuItem(
                                value: rol,
                                child: Text(rol),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            _rolSeleccionado = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Dropdown Estado
                      DropdownButtonFormField<String>(
                        value: _estadoSeleccionado,
                        decoration: const InputDecoration(
                          labelText: 'Estado',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.toggle_on),
                        ),
                        items: estadosDisponibles
                            .map(
                              (estado) => DropdownMenuItem(
                                value: estado,
                                child: Text(estado),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            _estadoSeleccionado = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _limpiarFormulario();
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: onGuardar,
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _mostrarCargando(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  void _mostrarSnackBar(String mensaje, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensaje), backgroundColor: color));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: ContentCard(
        title: 'Gestión de Usuarios',
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Administrar usuarios del sistema',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                ElevatedButton.icon(
                  onPressed: nuevoUsuario,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Nuevo Usuario'),
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
            _buildUserTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTable() {
    if (!_isFirebaseInitialized || _firestore == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore!.collection('usuarios').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No hay usuarios registrados'));
        }

        return Table(
          border: TableBorder.all(color: const Color(0xFFE2E8F0)),
          children: [
            TableRow(
              decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
              children: [
                _buildTableHeader('Nombre'),
                _buildTableHeader('Email'),
                _buildTableHeader('Rol'),
                _buildTableHeader('Estado'),
                _buildTableHeader('Acciones'),
              ],
            ),
            ...snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final userId = doc.id;

              return TableRow(
                children: [
                  _buildTableCell(data['nombre'] ?? 'Sin nombre'),
                  _buildTableCell(data['email'] ?? 'Sin email'),
                  _buildTableCell(data['rol'] ?? 'Sin rol'),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Chip(
                      label: Text(data['estado'] ?? 'Inactivo'),
                      backgroundColor: data['estado'] == 'Activo'
                          ? Colors.green[100]
                          : Colors.grey[300],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () => editarUsuario(userId, data),
                          tooltip: 'Editar',
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            size: 20,
                            color: Colors.red,
                          ),
                          onPressed: () => _eliminarUsuario(
                            userId,
                            data['nombre'] ?? 'Usuario',
                          ),
                          tooltip: 'Eliminar',
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ],
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
