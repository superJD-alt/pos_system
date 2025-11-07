import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/content_card.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({Key? key}) : super(key: key);

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  // Inicializar Firestore de forma segura
  FirebaseFirestore? _firestore;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _rolSeleccionado = 'Cajero';
  String _estadoSeleccionado = 'Activo';
  bool _isFirebaseInitialized = false;

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
  }

  Future<void> _crearUsuario() async {
    if (!_isFirebaseInitialized || _firestore == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Firebase no está inicializado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      try {
        // --- PASO 1: CREAR USUARIO EN FIREBASE AUTHENTICATION ---
        final UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(
              email: _emailController.text
                  .trim(), // Es buena práctica hacer trim()
              password: _passwordController.text,
            );

        final String userId = userCredential.user!.uid; // Obtenemos el UID

        // --- PASO 2: GUARDAR DATOS EN CLOUD FIRESTORE USANDO EL UID COMO DOC ID ---
        await _firestore!.collection('usuarios').doc(userId).set({
          'nombre': _nombreController.text,
          'email': _emailController.text,
          'rol': _rolSeleccionado,
          'estado': _estadoSeleccionado,
          'fechaCreacion': FieldValue.serverTimestamp(),
        });

        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuario creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } on FirebaseAuthException catch (e) {
        // Manejo de errores específicos de autenticación (email ya en uso, contraseña débil, etc.)
        String mensajeError = 'Error de autenticación: ${e.code}';
        if (e.code == 'weak-password') {
          mensajeError = 'La contraseña es demasiado débil.';
        } else if (e.code == 'email-already-in-use') {
          mensajeError = 'El email ya está registrado.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensajeError), backgroundColor: Colors.red),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear usuario: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Actualizar usuario en Firebase
  Future<void> _actualizarUsuario(String userId) async {
    if (!_isFirebaseInitialized || _firestore == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Firebase no está inicializado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      try {
        await _firestore!.collection('usuarios').doc(userId).update({
          'nombre': _nombreController.text,
          'email': _emailController.text,
          'rol': _rolSeleccionado,
          'estado': _estadoSeleccionado,
          'fechaActualizacion': FieldValue.serverTimestamp(),
        });

        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuario actualizado exitosamente'),
            backgroundColor: Colors.blue,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar usuario: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Eliminar usuario de Firebase
  Future<void> _eliminarUsuario(String userId, String nombre) async {
    if (!_isFirebaseInitialized || _firestore == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Firebase no está inicializado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text('¿Está seguro de eliminar a $nombre?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _firestore!.collection('usuarios').doc(userId).delete();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Usuario eliminado'),
                      backgroundColor: Colors.red,
                    ),
                  );
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al eliminar usuario: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
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
    _mostrarDialogoUsuario(titulo: 'Nuevo Usuario', onGuardar: _crearUsuario);
  }

  void editarUsuario(String userId, Map<String, dynamic> usuario) {
    _nombreController.text = usuario['nombre'] ?? '';
    _emailController.text = usuario['email'] ?? '';

    // Validar que el rol exista en las opciones disponibles
    final rolesDisponibles = ['Administrador', 'Cajero', 'Mesero', 'Cocinero'];
    _rolSeleccionado = rolesDisponibles.contains(usuario['rol'])
        ? usuario['rol']
        : 'Cajero';

    // Validar que el estado exista en las opciones disponibles
    final estadosDisponibles = ['Activo', 'Inactivo'];
    _estadoSeleccionado = estadosDisponibles.contains(usuario['estado'])
        ? usuario['estado']
        : 'Activo';

    _mostrarDialogoUsuario(
      titulo: 'Editar Usuario',
      onGuardar: () => _actualizarUsuario(userId),
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
                      TextFormField(
                        controller: _nombreController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre completo',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese el nombre';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese el email';
                          }
                          if (!value.contains('@')) {
                            return 'Por favor ingrese un email válido';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Contraseña',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true, // Para ocultar la contraseña
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese la contraseña';
                          }
                          if (value.length < 6) {
                            return 'La contraseña debe tener al menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
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
                  onPressed: () => Navigator.of(context).pop(),
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
                  '',
                  style: TextStyle(fontSize: 5, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: nuevoUsuario,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Nuevo Usuario'),
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
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Inicializando Firebase...'),
            ],
          ),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore!.collection('usuarios').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar usuarios: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(Icons.people_outline, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No hay usuarios registrados',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
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
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () => editarUsuario(userId, data),
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
