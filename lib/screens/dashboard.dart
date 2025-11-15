import 'package:flutter/material.dart';
import '../screens/panel_general.dart';
import '../screens/caja.dart';
import '../screens/inventario.dart';
import '../screens/reportes.dart';
import '../screens/usuarios.dart';
import '../screens/productos.dart';
import 'package:pos_system/screens/sidebar_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pos_system/pages/login_pos.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

  String _nombreUsuarioLogeado = 'Cargando...'; // Valor inicial
  String _correoUsuarioLogeado = 'cargando@pos.com'; // Valor inicial
  bool _isLoading = true; // Estado para mostrar un indicador de carga

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

  // Función para obtener los datos del usuario logeado con Firebase Auth
  void _cargarDatosUsuario() {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Usamos el displayName y email, si son null, usamos valores por defecto
      setState(() {
        _nombreUsuarioLogeado = user.displayName ?? user.email ?? 'Usuario POS';
        _correoUsuarioLogeado = user.email ?? 'sin_correo@pos.com';
        _isLoading = false;
      });
    } else {
      // Si no hay usuario logeado (caso de error, aunque no debería pasar en el Dashboard)
      setState(() {
        _nombreUsuarioLogeado = 'No Logeado';
        _correoUsuarioLogeado = 'acceso_denegado@pos.com';
        _isLoading = false;
      });
    }
  }

  void _onMenuItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _cerrarSesion() async {
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

    // Si el usuario confirmó el cierre (confirmacion es true)
    if (confirmacion == true) {
      try {
        await FirebaseAuth.instance.signOut();

        // Navegar a la pantalla de inicio de sesión
        if (mounted) {
          // Usa la alternativa de MaterialPageRoute para evitar el error de ruta
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              // Asegúrate de importar y usar tu widget de inicio de sesión aquí
              builder: (context) => const LoginPos(),
            ),
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
    // Si la información está cargando, mostramos un indicador de carga en el Sidebar
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
            onLogout: _cerrarSesion,
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
