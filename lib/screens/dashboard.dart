import 'package:flutter/material.dart';
import '../screens/panel_general.dart';
import '../screens/caja.dart';
import '../screens/inventario.dart';
import '../screens/reportes.dart';
import '../screens/usuarios.dart';
import '../screens/productos.dart';
// 🛑 CORRECCIÓN: La importación de SidebarMenu debe apuntar a la carpeta 'widgets'
import '../screens/sidebar_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pos_system/pages/login_pos.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;
  String _rolUsuario = 'cargando'; // Variable para almacenar el rol

  String _nombreUsuarioLogeado = 'Cargando...';
  String _correoUsuarioLogeado = 'cargando@pos.com';
  bool _isLoading = true;

  final List<String> _titles = [
    'Panel General',
    'Caja',
    'Inventario',
    'Reportes',
    'Usuarios',
    'Productos',
  ];

  // Lista de pantallas/páginas
  final List<Widget> _screens = [
    const PanelGeneralScreen(),
    const CajaScreen(),
    const InventarioScreen(),
    const ReportesScreen(),
    const UsuariosScreen(),
    const ProductosScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  void _cargarDatosUsuario() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // 1. Obtener el documento del usuario de la colección 'usuarios'
        final userDoc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .get();

        String nombreDB = '';
        String rolDB = 'unknown'; // Inicializar rol

        if (userDoc.exists) {
          // 2. Acceder a los campos de la base de datos
          nombreDB = userDoc.data()?['nombre'] ?? user.email;
          rolDB = userDoc.data()?['rol'] ?? 'unknown'; // Obtener el rol
        }

        setState(() {
          // 3. Actualizar estados
          _nombreUsuarioLogeado = nombreDB;
          _correoUsuarioLogeado = user.email ?? 'sin_correo@pos.com';
          _rolUsuario = rolDB; // Almacenar el rol
          _isLoading = false;
        });
      } catch (e) {
        print("Error al cargar datos de Firestore: $e");
        setState(() {
          // Fallback en caso de error de base de datos
          _nombreUsuarioLogeado =
              user.displayName ?? user.email ?? 'Error Nombre';
          _correoUsuarioLogeado = user.email ?? 'error@pos.com';
          _isLoading = false;
        });
      }
    } else {
      // Si no hay usuario logeado, forzamos la salida al login
      _cerrarSesionSinConfirmacion();
    }
  }

  void _onMenuItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Función auxiliar para cerrar sesión sin mostrar el diálogo (usada en caso de error o no logeado)
  Future<void> _cerrarSesionSinConfirmacion() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPos()),
        );
      }
    } catch (e) {
      print('Error al cerrar sesión (sin confirmación): $e');
      // No mostramos SnackBar aquí, ya que es un flujo de emergencia
    }
  }

  // FUNCIÓN PRINCIPAL LLAMADA POR EL SIDEBAR
  Future<void> _cerrarSesion() async {
    // 1. Mostrar diálogo de confirmación
    final bool? confirmacion = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que deseas cerrar la sesión?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Cancelar
              child: const Text('CANCELAR'),
            ),
            ElevatedButton(
              // Usamos 'true' para confirmar el cierre
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('CERRAR SESIÓN'),
            ),
          ],
        );
      },
    );

    // 2. Si el usuario confirmó el cierre (confirmacion es true)
    if (confirmacion == true) {
      try {
        // Ejecución de la salida de Firebase
        await FirebaseAuth.instance.signOut();

        // 3. Navegar a la pantalla de inicio de sesión
        if (mounted) {
          // Usamos pushReplacement para que el usuario no pueda volver al Dashboard con el botón de atrás
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginPos()),
          );
        }
      } catch (e) {
        print('Error al cerrar sesión: $e');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error al cerrar sesión: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String displayNombre = _isLoading
        ? 'Cargando...'
        : _nombreUsuarioLogeado;
    final String displayCorreo = _isLoading ? '...' : _correoUsuarioLogeado;

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          SidebarMenu(
            selectedIndex: _selectedIndex,
            onMenuItemSelected: _onMenuItemSelected,
            nombreUsuario: displayNombre,
            correoUsuario: displayCorreo,
            onLogout: _cerrarSesion, // Aquí se pasa la función _cerrarSesion
          ),
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Header
                _buildHeader(),
                // Content Area
                Expanded(child: _screens[_selectedIndex]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _titles[_selectedIndex],
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
