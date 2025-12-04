import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pos_system/pages/pedidos_activos.dart';
import 'package:pos_system/pages/login_pos.dart';
import 'package:pos_system/pages/view_table.dart';
import 'package:pos_system/pages/custom_table.dart';
import 'package:pos_system/pages/resumen_turno_page.dart';
import 'package:pos_system/pages/apartadoBotellaPage.dart';

class PanelMeseros extends StatefulWidget {
  const PanelMeseros({super.key});

  @override
  State<PanelMeseros> createState() => _PanelMeserosState();
}

class _PanelMeserosState extends State<PanelMeseros> {
  String nombreMesero = 'Cargando...';

  @override
  void initState() {
    super.initState();
    obtenerNombreMesero();
  }

  Future<void> obtenerNombreMesero() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        setState(() {
          nombreMesero = doc['nombre'] ?? 'Mesero';
        });
      } else {
        setState(() {
          nombreMesero = user.displayName ?? 'Mesero';
        });
      }
    } else {
      setState(() {
        nombreMesero = 'Invitado';
      });
    }
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
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('CANCELAR'),
            ),
            ElevatedButton(
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

    if (confirmacion == true) {
      try {
        await FirebaseAuth.instance.signOut();
        if (mounted) {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Meseros'),
        backgroundColor: Colors.indigoAccent,
        foregroundColor: Colors.white,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // ✅ Determinar si es pantalla pequeña, mediana o grande
          bool isSmallScreen = constraints.maxWidth < 600;
          bool isMediumScreen =
              constraints.maxWidth >= 600 && constraints.maxWidth < 1200;
          bool isLargeScreen = constraints.maxWidth >= 1200;

          return Container(
            color: Colors.grey.shade50,
            child: SafeArea(
              child: Column(
                children: [
                  // ✅ Contenido principal con scroll
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 16 : 40,
                        vertical: 40,
                      ),
                      child: Column(
                        children: [
                          // 🔹 Saludo al mesero
                          _buildGreeting(isSmallScreen),

                          SizedBox(height: isSmallScreen ? 30 : 40),

                          // 🔹 Botones principales (Nuevo pedido, Pedidos activos, Mesas)
                          _buildMainButtons(
                            constraints,
                            isSmallScreen,
                            isMediumScreen,
                          ),

                          SizedBox(height: isSmallScreen ? 40 : 60),

                          // 🔹 Botón Resumen del turno
                          _buildLargeActionButton(
                            context,
                            title: 'Resumen del turno',
                            color: Colors.orange,
                            page: const ResumenTurnoPage(),
                            isSmallScreen: isSmallScreen,
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  // ✅ Botones fijos en la parte inferior (responsivos)
                  _buildBottomButtons(
                    constraints,
                    isSmallScreen,
                    isMediumScreen,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ✅ Widget para el saludo (responsivo)
  Widget _buildGreeting(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 20 : 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigoAccent.shade400, Colors.indigoAccent.shade700],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.indigoAccent.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.waving_hand,
            size: isSmallScreen ? 32 : 40,
            color: Colors.white,
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              'Hola, $nombreMesero',
              style: TextStyle(
                fontSize: isSmallScreen ? 20 : 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Botones principales (responsivos según tamaño de pantalla)
  Widget _buildMainButtons(
    BoxConstraints constraints,
    bool isSmallScreen,
    bool isMediumScreen,
  ) {
    // Definir tamaño de iconos según pantalla
    double iconSize = isSmallScreen
        ? 120
        : isMediumScreen
        ? 180
        : 250;

    if (isSmallScreen) {
      // 📱 Pantallas pequeñas: 1 columna
      return Column(
        children: [
          _buildMainMenuButton(
            context,
            title: 'Nuevo pedido',
            icon: Icons.add,
            color: Colors.green,
            page: const CustomTable(),
            iconSize: iconSize,
          ),
          const SizedBox(height: 20),
          _buildMainMenuButton(
            context,
            title: 'Pedidos activos',
            icon: Icons.restaurant,
            color: Colors.blue,
            page: const PedidosActivosPage(),
            iconSize: iconSize,
          ),
          const SizedBox(height: 20),
          _buildMainMenuButton(
            context,
            title: 'Mesas',
            icon: Icons.table_restaurant,
            color: Colors.yellow,
            page: const ViewTable(),
            iconSize: iconSize,
          ),
        ],
      );
    } else {
      // 💻 Pantallas medianas y grandes: 3 columnas
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildMainMenuButton(
              context,
              title: 'Nuevo pedido',
              icon: Icons.add,
              color: Colors.green,
              page: const CustomTable(),
              iconSize: iconSize,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: _buildMainMenuButton(
              context,
              title: 'Pedidos activos',
              icon: Icons.restaurant,
              color: Colors.blue,
              page: const PedidosActivosPage(),
              iconSize: iconSize,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: _buildMainMenuButton(
              context,
              title: 'Mesas',
              icon: Icons.table_restaurant,
              color: Colors.yellow,
              page: const ViewTable(),
              iconSize: iconSize,
            ),
          ),
        ],
      );
    }
  }

  // ✅ Botones inferiores (responsivos)
  Widget _buildBottomButtons(
    BoxConstraints constraints,
    bool isSmallScreen,
    bool isMediumScreen,
  ) {
    if (isSmallScreen) {
      // 📱 Pantallas pequeñas: botones apilados verticalmente
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const apartadoBotellaPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.wine_bar, size: 24),
                label: const Text(
                  'Apartado Botellas',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _cerrarSesion,
                icon: const Icon(Icons.logout, size: 24),
                label: const Text(
                  'Cerrar sesión',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // 💻 Pantallas medianas y grandes: botones horizontales
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMediumScreen ? 24 : 40,
          vertical: 20,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Botón Apartado Botellas
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const apartadoBotellaPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.wine_bar, size: 24),
                  label: Text(
                    'Apartado Botellas',
                    style: TextStyle(
                      fontSize: isMediumScreen ? 16 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isMediumScreen ? 24 : 40,
                      vertical: isMediumScreen ? 16 : 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ),

            // Botón Cerrar sesión
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: ElevatedButton.icon(
                  onPressed: _cerrarSesion,
                  icon: const Icon(Icons.logout, size: 24),
                  label: Text(
                    'Cerrar sesión',
                    style: TextStyle(
                      fontSize: isMediumScreen ? 16 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isMediumScreen ? 24 : 40,
                      vertical: isMediumScreen ? 16 : 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  // Widget para los 3 botones grandes superiores (con tamaño de icono ajustable)
  Widget _buildMainMenuButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required Widget page,
    required double iconSize,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: 1, // Mantener proporción cuadrada
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => page),
              );
            },
            label: const Text(''),
            icon: Icon(icon, size: iconSize),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              side: const BorderSide(color: Colors.black, width: 8.0),
              padding: const EdgeInsets.all(20),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Widget para el botón de resumen del turno
  Widget _buildLargeActionButton(
    BuildContext context, {
    required String title,
    required Color color,
    required Widget page,
    required bool isSmallScreen,
  }) {
    return SizedBox(
      width: isSmallScreen ? double.infinity : null,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 40 : 80,
            vertical: isSmallScreen ? 16 : 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 6,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: isSmallScreen ? 18 : 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
