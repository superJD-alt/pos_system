import 'package:flutter/material.dart';
import '../screens/panel_general.dart';
import '../screens/caja.dart';
import '../screens/inventario.dart';
import '../screens/reportes.dart';
import '../screens/usuarios.dart';
import '../screens/productos.dart';
import 'package:pos_system/screens/sidebar_menu.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

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

  void _onMenuItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          SidebarMenu(
            selectedIndex: _selectedIndex,
            onMenuItemSelected: _onMenuItemSelected,
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
