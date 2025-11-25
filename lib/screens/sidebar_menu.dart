import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // No es necesario aquí, ya que la función onLogout viene del Dashboard

class SidebarMenu extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onMenuItemSelected;
  final String nombreUsuario;
  final String correoUsuario;
  final VoidCallback onLogout; // Propiedad para la función de cerrar sesión

  const SidebarMenu({
    Key? key,
    required this.selectedIndex,
    required this.onMenuItemSelected,
    required this.nombreUsuario,
    required this.correoUsuario,
    required this.onLogout, // Requerido
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: const Color(0xFF1E293B),
      child: Column(
        children: [
          // Logo/Header
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: const [
                Icon(Icons.point_of_sale, color: Colors.white, size: 32),
                SizedBox(width: 12),
                Text(
                  ' Parrilla Villa',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF334155), height: 1),
          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildMenuItem(0, Icons.dashboard, 'Panel General'),
                _buildMenuItem(1, Icons.point_of_sale, 'Caja'),
                _buildMenuItem(2, Icons.inventory, 'Inventario'),
                _buildMenuItem(3, Icons.assessment, 'Reportes'),
                _buildMenuItem(4, Icons.people, 'Usuarios'),
                _buildMenuItem(5, Icons.shopping_bag, 'Menu'),
              ],
            ),
          ),

          // Perfil de Usuario con Menú Desplegable (Cerrar Sesión)
          _buildUserProfileMenu(context),
        ],
      ),
    );
  }

  Widget _buildMenuItem(int index, IconData icon, String title) {
    final isSelected = selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Colors.white : const Color(0xFF94A3B8),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF94A3B8),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: () => onMenuItemSelected(index),
      ),
    );
  }

  // --- FUNCIÓN CORREGIDA ---
  Widget _buildUserProfileMenu(BuildContext context) {
    return PopupMenuButton<String>(
      // 1. EL WIDGET QUE SE MUESTRA SIEMPRE
      child: Container(
        padding: const EdgeInsets.all(16),
        child: InkWell(
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFF3B82F6),
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombreUsuario,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: const [
                        Text(
                          'Opciones ',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        // Cambiado a drop_down para indicar que el menú se abre hacia arriba o abajo
                        Icon(
                          Icons.arrow_drop_down,
                          color: Color(0xFF94A3B8),
                          size: 16,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // 2. LAS OPCIONES QUE SE DESPLIEGAN
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          enabled: false,
          child: Text(
            correoUsuario,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const PopupMenuDivider(),

        // Opción de Cerrar Sesión
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: const [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 8),
              Text('Cerrar Sesión'),
            ],
          ),
        ),
      ],

      // 3. ✅ EL LISTENER QUE EJECUTA LA ACCIÓN (LO QUE FALTABA)
      onSelected: (String result) {
        if (result == 'logout') {
          // Llama a la función onLogout proporcionada por el widget padre (Dashboard)
          onLogout();
        }
      },
    );
  }
}
